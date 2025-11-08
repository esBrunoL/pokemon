import 'package:flutter/material.dart';
import '../models/pokemon_card.dart';
import '../services/api_service.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  PokemonCard? card1;
  PokemonCard? card2;
  String? winner;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRandomCards();
  }

  Future<void> _loadRandomCards() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      winner = null;
    });

    try {
      final apiService = PokemonApiService();
      final cards = await apiService.getRandomCards(count: 2);
      if (cards.length >= 2) {
        setState(() {
          card1 = cards[0];
          card2 = cards[1];
          _determineWinner();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Could not fetch enough Pokemon';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading Pokemon: $e';
        isLoading = false;
      });
    }
  }

  void _determineWinner() {
    if (card1 != null && card2 != null) {
      final hp1 = card1!.hpValue;
      final hp2 = card2!.hpValue;

      if (hp1 > hp2) {
        winner = '${card1!.name.toUpperCase()} WINS! ($hp1 HP vs $hp2 HP)';
      } else if (hp2 > hp1) {
        winner = '${card2!.name.toUpperCase()} WINS! ($hp2 HP vs $hp1 HP)';
      } else {
        winner = 'IT\'S A TIE! (Both have $hp1 HP)';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Pokemon Card Battle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red.shade800,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Error message
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),

            // Loading indicator
            if (isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Loading Pokemon cards...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Cards display
              Expanded(
                child: Row(
                  children: [
                    // Card 1
                    Expanded(
                      child: _buildCardWidget(card1, 'Card 1'),
                    ),
                    const SizedBox(width: 16),
                    // VS Text
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Card 2
                    Expanded(
                      child: _buildCardWidget(card2, 'Card 2'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Winner declaration
              if (winner != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: Text(
                    winner!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Battle button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _loadRandomCards,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red, width: 2),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'NEW BATTLE!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardWidget(PokemonCard? card, String placeholder) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 3),
      ),
      child: card == null
          ? SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  placeholder,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                // Card image
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: card.imageUrl.isNotEmpty
                          ? Image.network(
                              card.imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(color: Colors.red),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.red,
                                size: 50,
                              ),
                            ),
                    ),
                  ),
                ),
                // Card info
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          card.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'HP: ${card.hp}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (card.types.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: card.types
                                .map((type) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(type),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        type.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.red.shade700;
      case 'water':
        return Colors.blue.shade700;
      case 'grass':
        return Colors.green.shade700;
      case 'electric':
        return Colors.yellow.shade700;
      case 'psychic':
        return Colors.purple.shade700;
      case 'ice':
        return Colors.lightBlue.shade700;
      case 'dragon':
        return Colors.indigo.shade700;
      case 'dark':
        return Colors.grey.shade800;
      case 'fairy':
        return Colors.pink.shade400;
      case 'fighting':
        return Colors.brown.shade700;
      case 'poison':
        return Colors.deepPurple.shade700;
      case 'ground':
        return Colors.orange.shade700;
      case 'flying':
        return Colors.lightBlue.shade400;
      case 'bug':
        return Colors.lightGreen.shade700;
      case 'rock':
        return Colors.brown.shade400;
      case 'ghost':
        return Colors.purple.shade900;
      case 'steel':
        return Colors.blueGrey.shade700;
      case 'normal':
      default:
        return Colors.grey.shade600;
    }
  }
}
