import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import '../models/pokemon_card.dart';
import '../services/api_service.dart';

class CardListProvider extends ChangeNotifier {
  CardListProvider(this._apiService);
  final PokemonApiService _apiService;

  // State variables
  List<PokemonCard> _cards = [];
  List<PokemonCard> _filteredCards = [];
  LoadingState _loadingState = LoadingState.initial;
  ApiError? _error;
  String _searchQuery = '';
  int _currentPage = 1;
  bool _hasMorePages = true;

  // Search debouncing
  Timer? _searchDebounceTimer;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 500);

  // Getters
  List<PokemonCard> get cards => _filteredCards;
  LoadingState get loadingState => _loadingState;
  ApiError? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasMorePages => _hasMorePages;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get isLoadingMore => _loadingState == LoadingState.loadingMore;
  bool get hasError => _error != null;
  bool get isEmpty => _cards.isEmpty;
  bool get isSearching => _searchQuery.isNotEmpty;

  /// Initialize the card list
  Future<void> initialize() async {
    if (_loadingState != LoadingState.initial) return;

    await loadCards();
  }

  /// Load cards from API
  Future<void> loadCards({bool isLoadingMore = false}) async {
    if (isLoadingMore && (!_hasMorePages || _loadingState == LoadingState.loadingMore)) {
      return;
    }

    _setLoadingState(isLoadingMore ? LoadingState.loadingMore : LoadingState.loading);
    _error = null;

    try {
      final page = isLoadingMore ? _currentPage + 1 : 1;
      final response = await _apiService.getCards(
        page: page,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );

      if (isLoadingMore) {
        _cards.addAll(response.data);
        _currentPage++;
      } else {
        _cards = response.data;
        _currentPage = 1;
      }

      _hasMorePages = response.hasMore;
      _applySearchFilter();
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _error = e is ApiError
          ? e
          : ApiError(
              message: 'Failed to load cards',
              details: e.toString(),
            );
      _setLoadingState(LoadingState.error);
    }
  }

  /// Load more cards (infinite scroll)
  Future<void> loadMoreCards() async {
    await loadCards(isLoadingMore: true);
  }

  /// Search cards with debouncing
  void searchCards(String query) {
    _searchQuery = query;

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Apply immediate local filtering for better UX
    _applySearchFilter();

    _searchDebounceTimer = Timer(_searchDebounceDelay, _performApiSearch);
  }

  /// Clear search and show all cards
  void clearSearch() {
    _searchQuery = '';
    _searchDebounceTimer?.cancel();
    _applySearchFilter();
    notifyListeners();
  }

  /// Retry loading cards after error
  Future<void> retry() async {
    await loadCards();
  }

  /// Refresh cards (pull to refresh)
  Future<void> refresh() async {
    _currentPage = 1;
    _hasMorePages = true;
    await loadCards();
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _apiService.clearCache();
    _cards.clear();
    _filteredCards.clear();
    _currentPage = 1;
    _hasMorePages = true;
    _setLoadingState(LoadingState.initial);
    notifyListeners();
  }

  /// Apply search filter to local cards
  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredCards = List.from(_cards);
    } else {
      _filteredCards = _cards.where((card) => card.matchesSearch(_searchQuery)).toList();
    }
    notifyListeners();
  }

  /// Perform API search
  Future<void> _performApiSearch() async {
    if (_searchQuery.isEmpty) {
      await loadCards(); // Load all cards
    } else {
      await loadCards(); // Load with search query
    }
  }

  /// Set loading state and notify listeners
  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _apiService.dispose();
    super.dispose();
  }
}
