import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/api_models.dart';
import '../state/card_list_provider.dart';
import '../widgets/card_grid_item.dart';
import 'card_detail_screen.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final ScrollController _scrollController = ScrollController();

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
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CardListProvider>(
        builder: (context, provider, child) {
          if (provider.loadingState == LoadingState.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.isSearching
                        ? 'waiting for pokedex server...'
                        : 'Your pokédex is waking up...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
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
                  const Text(
                    'Your pokédex lost contact with the server, try again later',
                    style: TextStyle(
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
                'No Pokémon found',
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
              itemCount: provider.cards.length + (provider.isLoadingMore ? 1 : 0),
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
    );
  }
}
