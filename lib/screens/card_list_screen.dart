import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/api_models.dart';
import '../state/card_list_provider.dart';
import '../widgets/card_grid_item.dart';
import '../widgets/search_bar.dart';
import 'card_detail_screen.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initialize the card list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardListProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..addListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more cards when user is near the bottom
      context.read<CardListProvider>().loadMoreCards();
    }
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < 500) {
      return 1; // 1 container per row on small screens
    } else {
      // Minimum container width of 250px
      return (screenWidth / 250).floor().clamp(1, 10);
    }
  }

  void _showCardDetail(BuildContext context, card) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CardDetailDialog(card: card),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);

    return Focus(
      onKeyEvent: (node, event) {
        // Handle Escape key to close search
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          if (_isSearchVisible) {
            setState(() {
              _isSearchVisible = false;
            });
            context.read<CardListProvider>().clearSearch();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Pokémon TCG Browser'),
          backgroundColor: Colors.black,
          actions: [
            Semantics(
              label: _isSearchVisible ? 'Close search' : 'Search cards',
              child: IconButton(
                icon: Icon(
                  _isSearchVisible ? Icons.close : Icons.search,
                ),
                onPressed: () {
                  setState(() {
                    _isSearchVisible = !_isSearchVisible;
                  });
                  if (!_isSearchVisible) {
                    context.read<CardListProvider>().clearSearch();
                  }
                },
              ),
            ),
            Semantics(
              label: 'Refresh cards',
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<CardListProvider>().refresh();
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar (conditionally visible)
            if (_isSearchVisible)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  border: Border(
                    bottom: BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                child: PokemonSearchBar(
                  onSearchChanged: (query) {
                    context.read<CardListProvider>().searchCards(query);
                  },
                ),
              ),

            // Card list
            Expanded(
              child: Consumer<CardListProvider>(
                builder: (context, provider, child) {
                  if (provider.loadingState == LoadingState.loading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            'Loading Pokémon cards...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.error?.message ?? 'An error occurred',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.retry(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Pokémon cards found',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.refresh(),
                    color: Colors.red,
                    backgroundColor: Colors.black,
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.7, // Adjust for card proportions
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: provider.cards.length +
                          (provider.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.cards.length) {
                          // Loading indicator for infinite scroll
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.red),
                          );
                        }

                        final card = provider.cards[index];
                        return CardGridItem(
                          card: card,
                          onTap: () => _showCardDetail(context, card),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
