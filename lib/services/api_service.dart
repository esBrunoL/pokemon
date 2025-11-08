import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';
import '../models/pokemon_card.dart';
import '../models/type_effectiveness.dart';

class PokemonApiService {
  PokemonApiService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final String _baseUrl = 'https://pokeapi.co/api/v2';
  final http.Client _httpClient;
  final Map<String, List<PokemonCard>> _cache = {};
  final Map<String, TypeEffectiveness> _typeEffectivenessCache = {};
  static const int _defaultPageSize = 20;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Rate limiting
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 100);

  /// Headers for API requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  /// Get Pokemon with pagination and optional search
  Future<PaginatedResponse<PokemonCard>> getCards({
    int page = 1,
    int pageSize = _defaultPageSize,
    String? searchQuery,
    String orderBy = 'id',
  }) async {
    await _respectRateLimit();

    final cacheKey = _buildCacheKey(page, pageSize, searchQuery, orderBy);

    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cachedCards = _cache[cacheKey]!;
      return PaginatedResponse<PokemonCard>(
        data: cachedCards,
        page: page,
        pageSize: pageSize,
        totalCount: cachedCards.length,
        hasMore: cachedCards.length == pageSize,
      );
    }

    try {
      List<PokemonCard> cards = [];

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // For search, we need to load a larger dataset and filter locally
        // since PokeAPI doesn't support fuzzy search
        cards = await _performSearchWithLocalFiltering(searchQuery, pageSize);
      } else {
        // Get Pokemon list with pagination
        cards = await _getPokemonList(page, pageSize);
      }

      // Cache the results
      _cache[cacheKey] = cards;
      await _saveCacheToLocal(cacheKey, cards);

      return PaginatedResponse<PokemonCard>(
        data: cards,
        page: page,
        pageSize: pageSize,
        totalCount: cards.length,
        hasMore: cards.length == pageSize,
      );
    } catch (e) {
      // Try to load from local cache if available
      final localCards = await _loadCacheFromLocal(cacheKey);
      if (localCards.isNotEmpty) {
        debugPrint('API request failed, using cached data: $e');
        return PaginatedResponse<PokemonCard>(
          data: localCards,
          page: page,
          pageSize: pageSize,
          totalCount: localCards.length,
          hasMore: false,
        );
      }

      // If API fails and no cache available, rethrow the error
      debugPrint('API request failed with no cache available: $e');
      rethrow;
    }
  }

  /// Get a list of Pokemon with pagination
  Future<List<PokemonCard>> _getPokemonList(int page, int pageSize) async {
    final offset = (page - 1) * pageSize;
    final url = Uri.parse('$_baseUrl/pokemon?limit=$pageSize&offset=$offset');
    final response = await _makeRequestWithRetry(url);

    final jsonData = json.decode(response.body) as Map<String, dynamic>;
    final results = jsonData['results'] as List<dynamic>? ?? [];

    // Fetch detailed data for each Pokemon
    List<PokemonCard> cards = [];
    for (final result in results) {
      final pokemonUrl = result['url'] as String;
      final pokemonId = pokemonUrl.split('/').where((s) => s.isNotEmpty).last;
      final pokemon = await getPokemonById(pokemonId);
      if (pokemon != null) {
        cards.add(pokemon);
      }
    }

    return cards;
  }

  /// Perform search with local filtering for partial matches
  Future<List<PokemonCard>> _performSearchWithLocalFiltering(String query, int limit) async {
    // Use smart name-based filtering from the start to avoid 404 errors
    // Get matching Pokemon names first, then fetch only the matching ones
    final matchingPokemon = await _findMatchingPokemonNames(query, limit);

    // Fetch detailed data for matching Pokemon
    final List<PokemonCard> results = [];
    for (final pokemonName in matchingPokemon) {
      final pokemon = await getPokemonById(pokemonName);
      if (pokemon != null) {
        results.add(pokemon);
        if (results.length >= limit) break; // Limit results
      }
    }

    return results;
  }

  /// Find Pokemon names that match the search query without fetching full data
  Future<List<String>> _findMatchingPokemonNames(String query, int limit) async {
    final lowerQuery = query.toLowerCase();

    // Check if we have a cached list of all Pokemon names
    const cacheKey = 'pokemon_names_list';
    if (_cache.containsKey(cacheKey)) {
      final cachedNames = _cache[cacheKey]?.map((card) => card.name).toList() ?? [];
      return cachedNames
          .where((name) => name.toLowerCase().contains(lowerQuery))
          .take(limit * 2) // Get a few more to account for failed fetches
          .toList();
    }

    // If not cached, get a reasonable list (first 1008 Pokemon as of 2024)
    try {
      final url = Uri.parse('$_baseUrl/pokemon?limit=1008&offset=0');
      final response = await _makeRequestWithRetry(url);
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final results = jsonData['results'] as List<dynamic>? ?? [];

      // Extract names and filter
      final allNames = results.map((item) => item['name'] as String).toList();
      final matchingNames = allNames
          .where((name) => name.toLowerCase().contains(lowerQuery))
          .take(limit * 2)
          .toList();

      return matchingNames;
    } catch (e) {
      debugPrint('Failed to get Pokemon names list: $e');
      // Fallback to original method with smaller dataset
      final cards = await _getPokemonList(1, 151);
      return cards
          .where((card) => _matchesSearchQuery(card, query))
          .map((card) => card.name)
          .take(limit)
          .toList();
    }
  }

  /// Check if a Pokemon card matches the search query
  bool _matchesSearchQuery(PokemonCard card, String query) {
    final lowerQuery = query.toLowerCase();

    // Check if it's a number (Pokédex number search)
    final number = int.tryParse(query);
    if (number != null) {
      return card.pokedexNumber == number;
    }

    // Text search in name and types
    return card.name.toLowerCase().contains(lowerQuery) ||
        card.types.any((type) => type.toLowerCase().contains(lowerQuery)) ||
        card.abilities.any((ability) => ability.toLowerCase().contains(lowerQuery));
  }

  /// Search cards by name or ID
  Future<List<PokemonCard>> searchCards(String query) async {
    if (query.isEmpty) return [];

    // Use the optimized search method instead of direct API call
    return await _performSearchWithLocalFiltering(query, 20);
  }

  /// Get a specific Pokemon by ID or name
  Future<PokemonCard?> getPokemonById(String identifier) async {
    await _respectRateLimit();

    try {
      final url = Uri.parse('$_baseUrl/pokemon/$identifier');
      final response = await _makeRequestWithRetry(url);

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      return PokemonCard.fromJson(jsonData);
    } catch (e) {
      debugPrint('Failed to fetch Pokemon with identifier: $identifier, error: $e');
      return null;
    }
  }

  /// Get a specific card by ID (alias for getPokemonById for compatibility)
  Future<PokemonCard?> getCardById(String cardId) async {
    return await getPokemonById(cardId);
  }

  /// Get random Pokemon cards for battle functionality
  Future<List<PokemonCard>> getRandomCards({int count = 2}) async {
    try {
      final cards = <PokemonCard>[];
      final usedIds = <int>{};

      // There are over 1000 Pokemon, but let's use the first 898 (original + expansions)
      // to ensure we get valid Pokemon with proper data
      while (cards.length < count && usedIds.length < 50) {
        // Safety limit
        final randomId = (cards.length * 137 + DateTime.now().millisecondsSinceEpoch) % 898 + 1;

        if (usedIds.contains(randomId)) continue;
        usedIds.add(randomId);

        try {
          final pokemon = await getPokemonById(randomId.toString());

          // Only add Pokemon with valid HP and image
          if (pokemon != null && pokemon.hpValue > 0 && pokemon.imageUrl.isNotEmpty) {
            cards.add(pokemon);
          }
        } catch (e) {
          debugPrint('Error fetching random Pokemon $randomId: $e');
          continue;
        }
      }

      if (cards.length < count) {
        // Fallback: get some well-known Pokemon if random selection fails
        return await _getFallbackPokemon(count: count);
      }

      return cards;
    } catch (e) {
      throw Exception('Error fetching random Pokemon: $e');
    }
  }

  /// Fallback method to get popular/well-known Pokemon
  Future<List<PokemonCard>> _getFallbackPokemon({int count = 2}) async {
    final popularPokemonIds = [
      1,
      4,
      7,
      25,
      39,
      52,
      104,
      113,
      131,
      143,
      150,
      151
    ]; // Bulbasaur, Charmander, Squirtle, Pikachu, etc.
    final cards = <PokemonCard>[];

    // Shuffle the list and take the required count
    popularPokemonIds.shuffle();
    final selectedIds = popularPokemonIds.take(count).toList();

    for (final id in selectedIds) {
      try {
        final pokemon = await getPokemonById(id.toString());
        if (pokemon != null) {
          cards.add(pokemon);
        }
      } catch (e) {
        debugPrint('Error fetching fallback Pokemon $id: $e');
      }
    }

    return cards;
  }

  /// Make an HTTP request with retry logic
  Future<http.Response> _makeRequestWithRetry(Uri url) async {
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await _httpClient
            .get(
              url,
              headers: _headers,
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode == 429) {
          // Rate limit exceeded, wait longer
          await Future.delayed(_retryDelay * (attempt + 2));
          continue;
        } else if (response.statusCode == 404) {
          throw ApiError(
            message: 'Pokemon not found',
            statusCode: response.statusCode,
            details: response.body,
          );
        } else {
          throw ApiError(
            message: 'API request failed',
            statusCode: response.statusCode,
            details: response.body,
          );
        }
      } on SocketException {
        if (attempt == _maxRetries - 1) {
          throw const ApiError(
            message: 'No internet connection. Please check your network.',
          );
        }
        await Future.delayed(_retryDelay * (attempt + 1));
      } on TimeoutException {
        if (attempt == _maxRetries - 1) {
          throw const ApiError(
            message: 'Request timed out. Please try again.',
          );
        }
        await Future.delayed(_retryDelay * (attempt + 1));
      } catch (e) {
        if (attempt == _maxRetries - 1) {
          throw ApiError(
            message: 'An unexpected error occurred',
            details: e.toString(),
          );
        }
        await Future.delayed(_retryDelay * (attempt + 1));
      }
    }

    throw const ApiError(message: 'Failed to complete request after retries');
  }

  /// Respect rate limiting
  Future<void> _respectRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final delay = _minRequestInterval - timeSinceLastRequest;
        await Future.delayed(delay);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Build cache key
  String _buildCacheKey(int page, int pageSize, String? searchQuery, String orderBy) {
    return 'pokemon_${page}_${pageSize}_${searchQuery ?? ''}_$orderBy';
  }

  /// Save cache to local storage
  Future<void> _saveCacheToLocal(String key, List<PokemonCard> cards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(cards.map((card) => card.toJson()).toList());
      await prefs.setString('cache_$key', jsonString);
    } catch (e) {
      // Ignore cache save errors
    }
  }

  /// Load cache from local storage
  Future<List<PokemonCard>> _loadCacheFromLocal(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cache_$key');
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        return jsonList.map((item) => PokemonCard.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Ignore cache load errors
    }
    return [];
  }

  /// Get type effectiveness data for a specific type
  Future<TypeEffectiveness?> getTypeEffectiveness(String typeName) async {
    final lowerTypeName = typeName.toLowerCase();

    // Check memory cache
    if (_typeEffectivenessCache.containsKey(lowerTypeName)) {
      return _typeEffectivenessCache[lowerTypeName];
    }

    // Check local storage cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('type_$lowerTypeName');
      if (cachedJson != null) {
        final typeData = TypeEffectiveness.fromJson(json.decode(cachedJson));
        _typeEffectivenessCache[lowerTypeName] = typeData;
        return typeData;
      }
    } catch (e) {
      debugPrint('Error loading cached type data: $e');
    }

    // Fetch from API
    try {
      await _respectRateLimit();
      final url = Uri.parse('$_baseUrl/type/$lowerTypeName');
      final response = await _makeRequestWithRetry(url);

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final typeData = TypeEffectiveness.fromJson(jsonData);

      // Cache in memory and local storage
      _typeEffectivenessCache[lowerTypeName] = typeData;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('type_$lowerTypeName', json.encode(jsonData));
      } catch (e) {
        debugPrint('Error caching type data: $e');
      }

      return typeData;
    } catch (e) {
      debugPrint('Error fetching type effectiveness: $e');
      return null;
    }
  }

  /// Get all type effectiveness data for multiple types
  /// Used for initializing the type effectiveness calculator
  Future<Map<String, TypeEffectiveness>> getAllTypeEffectiveness() async {
    const allTypes = [
      'normal',
      'fire',
      'water',
      'electric',
      'grass',
      'ice',
      'fighting',
      'poison',
      'ground',
      'flying',
      'psychic',
      'bug',
      'rock',
      'ghost',
      'dragon',
      'dark',
      'steel',
      'fairy'
    ];

    final Map<String, TypeEffectiveness> typeData = {};

    for (final typeName in allTypes) {
      final effectiveness = await getTypeEffectiveness(typeName);
      if (effectiveness != null) {
        typeData[typeName] = effectiveness;
      }
    }

    return typeData;
  }

  /// Create a type effectiveness calculator with cached data
  Future<TypeEffectivenessCalculator> getTypeEffectivenessCalculator() async {
    final typeData = await getAllTypeEffectiveness();
    return TypeEffectivenessCalculator(typeData);
  }

  /// Clear all caches
  Future<void> clearCache() async {
    _cache.clear();
    _typeEffectivenessCache.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys =
          prefs.getKeys().where((key) => key.startsWith('cache_') || key.startsWith('type_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Ignore cache clear errors
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}

// Legacy compatibility class - remove the duplicate ApiService class
class ApiService {
  final String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<dynamic>> fetchPokemonCards({int page = 1, int pageSize = 20}) async {
    final offset = (page - 1) * pageSize;
    final url = Uri.parse('$baseUrl/pokemon?limit=$pageSize&offset=$offset');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to fetch Pokémon: ${response.statusCode}');
    }
  }
}
