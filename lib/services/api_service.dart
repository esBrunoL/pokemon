import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_models.dart';
import '../models/pokemon_card.dart';
import 'mock_data.dart';

class PokemonTcgApiService {
  PokemonTcgApiService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client() {
    _apiKey = dotenv.env['POKEMON_TCG_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('Pokemon TCG API key not found. Please check your .env file.');
    }
  }

  final String _baseUrl = 'https://late-glitter-4565.brunolobo-14.workers.dev';
  late final String _apiKey;
  final http.Client _httpClient;
  final Map<String, List<PokemonCard>> _cache = {};
  static const int _defaultPageSize = 20;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Rate limiting
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 50);

  /// Headers for API requests
  Map<String, String> get _headers => {
        'X-Api-Key': _apiKey,
        'Content-Type': 'application/json',
      };

  /// Get cards with pagination and optional search
  Future<PaginatedResponse<PokemonCard>> getCards({
    int page = 1,
    int pageSize = _defaultPageSize,
    String? searchQuery,
    String orderBy = 'nationalPokedexNumbers',
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
      final url = _buildUrl('cards', page, pageSize, searchQuery, orderBy);
      final response = await _makeRequestWithRetry(url);

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final cards = _parseCardsFromResponse(jsonData);

      // Cache the results
      _cache[cacheKey] = cards;
      await _saveCacheToLocal(cacheKey, cards);

      return PaginatedResponse<PokemonCard>(
        data: cards,
        page: page,
        pageSize: pageSize,
        totalCount: jsonData['totalCount'] ?? cards.length,
        hasMore: cards.length == pageSize,
      );
    } catch (e) {
      // Try to load from local cache if available
      final localCards = await _loadCacheFromLocal(cacheKey);
      if (localCards.isNotEmpty) {
        return PaginatedResponse<PokemonCard>(
          data: localCards,
          page: page,
          pageSize: pageSize,
          totalCount: localCards.length,
          hasMore: false,
        );
      }

      // If API fails (e.g., CORS issues in web), use mock data
      debugPrint('API request failed, using mock data: $e');
      final mockCards = _getMockCards(searchQuery);

      // Cache mock data
      _cache[cacheKey] = mockCards;

      return PaginatedResponse<PokemonCard>(
        data: mockCards,
        page: page,
        pageSize: pageSize,
        totalCount: mockCards.length,
        hasMore: false,
      );
    }
  }

  /// Search cards by name or national Pokedex number
  Future<List<PokemonCard>> searchCards(String query) async {
    if (query.isEmpty) return [];

    // Check if query is a number (Pokedex search)
    final number = int.tryParse(query);
    final searchQuery = number != null ? 'nationalPokedexNumbers:$number' : 'name:*$query*';

    final response = await getCards(
      searchQuery: searchQuery,
      pageSize: 100, // Smaller page size for search
    );

    return response.data;
  }

  /// Get a specific card by ID
  Future<PokemonCard?> getCardById(String cardId) async {
    await _respectRateLimit();

    try {
      final url = Uri.parse('$_baseUrl/cards/$cardId');
      final response = await _makeRequestWithRetry(url);

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final cardData = jsonData['data'] as Map<String, dynamic>?;

      if (cardData != null) {
        return PokemonCard.fromJson(cardData);
      }
      return null;
    } catch (e) {
      throw ApiError(
        message: 'Failed to fetch card with ID: $cardId',
        details: e.toString(),
      );
    }
  }

  /// Build URL with query parameters
  Uri _buildUrl(String endpoint, int page, int pageSize, String? searchQuery, String orderBy) {
    final queryParameters = {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'orderBy': orderBy,
      'select':
          'id,name,images,rarity,set,evolvesFrom,evolvesTo,nationalPokedexNumbers,supertype,subtypes',
    };

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParameters['q'] = searchQuery;
    }

    return Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: queryParameters);
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

  /// Parse cards from API response
  List<PokemonCard> _parseCardsFromResponse(Map<String, dynamic> jsonData) {
    final dataList = jsonData['data'] as List<dynamic>? ?? [];
    return dataList.map((item) => PokemonCard.fromJson(item as Map<String, dynamic>)).toList();
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
    return 'cards_${page}_${pageSize}_${searchQuery ?? ''}_$orderBy';
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

  /// Clear all caches
  Future<void> clearCache() async {
    _cache.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('cache_'));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Ignore cache clear errors
    }
  }

  /// Get mock cards for demonstration when API is not available
  List<PokemonCard> _getMockCards(String? searchQuery) {
    final mockData = mockApiResponse['data'] as List<dynamic>;
    var cards = mockData.map((item) => PokemonCard.fromJson(item as Map<String, dynamic>)).toList();

    // Sort by national pokedex numbers
    cards.sort((a, b) {
      final aNum = a.nationalPokedexNumbers.isNotEmpty ? a.nationalPokedexNumbers.first : 999;
      final bNum = b.nationalPokedexNumbers.isNotEmpty ? b.nationalPokedexNumbers.first : 999;
      return aNum.compareTo(bNum);
    });

    // Apply search filter if provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (searchQuery.contains('nationalPokedexNumbers:')) {
        final numberStr = searchQuery.split(':')[1];
        final number = int.tryParse(numberStr);
        if (number != null) {
          cards = cards.where((card) => card.nationalPokedexNumbers.contains(number)).toList();
        }
      } else if (searchQuery.contains('name:')) {
        final nameQuery = searchQuery.split(':')[1].replaceAll('*', '').toLowerCase();
        cards = cards.where((card) => card.name.toLowerCase().contains(nameQuery)).toList();
      }
    }

    return cards;
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}

class ApiService {
  final String baseUrl = 'https://late-glitter-4565.brunolobo-14.workers.dev';

  Future<List<dynamic>> fetchPokemonCards({int page = 1, int pageSize = 20}) async {
    final url = Uri.parse('$baseUrl?page=$page&pageSize=$pageSize&orderBy=nationalPokedexNumbers');
    print('Fetching URL: $url'); // Debugging line to check the URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to fetch Pokémon cards: ${response.statusCode}');
    }
  }
}

// Add logic to handle CORS issues for web deployment
// For GitHub Pages compatibility, consider using a serverless proxy solution like Cloudflare Workers or Netlify Functions.
