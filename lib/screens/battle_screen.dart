import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/pokemon_card.dart';
import '../services/api_service.dart';
import '../widgets/pokedex_frame_wrapper.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  PokemonCard? playerPokemon;
  PokemonCard? opponentPokemon;
  PokemonCard? winnerPokemon;
  bool isLoading = false;
  String? errorMessage;
  bool battleComplete = false;

  @override
  void initState() {
    super.initState();
    _startNewBattle();
  }

  Future<void> _startNewBattle() async {
    setState(() {
      isLoading = true;
      battleComplete = false;
      winnerPokemon = null;
      errorMessage = null;
    });

    try {
      final apiService = PokemonApiService();

      // Generate two random Pokemon IDs
      final random = Random();
      final playerId = random.nextInt(1008) + 1;
      final opponentId = random.nextInt(1008) + 1;

      // Fetch both Pokemon concurrently
      final futures = await Future.wait([
        apiService.getPokemonById(playerId.toString()),
        apiService.getPokemonById(opponentId.toString()),
      ]);

      final fetchedPlayerPokemon = futures[0];
      final fetchedOpponentPokemon = futures[1];

      if (fetchedPlayerPokemon == null || fetchedOpponentPokemon == null) {
        throw Exception('Failed to fetch Pokemon data');
      }

      setState(() {
        playerPokemon = fetchedPlayerPokemon;
        opponentPokemon = fetchedOpponentPokemon;
      });

      await _simulateBattle();
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading Pokemon: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _simulateBattle() async {
    if (playerPokemon == null || opponentPokemon == null) return;

    // Get attack stats
    final playerAttack = playerPokemon!.stats
        .firstWhere(
          (stat) => stat.name == 'attack',
          orElse: () => const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
        )
        .baseStat;

    final opponentAttack = opponentPokemon!.stats
        .firstWhere(
          (stat) => stat.name == 'attack',
          orElse: () => const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
        )
        .baseStat;

    // Calculate type effectiveness
    double playerEffectiveness = 1.0;
    double opponentEffectiveness = 1.0;

    // Simplified effectiveness calculation
    // In a real implementation, you would use the TypeEffectiveness class
    // For now, just use basic attack comparison

    final adjustedPlayerAttack = (playerAttack * playerEffectiveness).round();
    final adjustedOpponentAttack = (opponentAttack * opponentEffectiveness).round();

    // Determine winner
    PokemonCard? winner;
    if (adjustedPlayerAttack > adjustedOpponentAttack) {
      winner = playerPokemon;
    } else if (adjustedOpponentAttack > adjustedPlayerAttack) {
      winner = opponentPokemon;
    }
    // If tied, winner remains null

    // Add some delay for dramatic effect
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      winnerPokemon = winner;
      battleComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerWon = winnerPokemon == playerPokemon;

    return PokedexFrameWrapper(
      screenTitle: 'Try outs!',
      showSearch: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            if (battleComplete)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: winnerPokemon == null
                        ? [Colors.orange.shade700, Colors.orange.shade900]
                        : playerWon
                            ? [Colors.green.shade700, Colors.green.shade900]
                            : [Colors.red.shade700, Colors.red.shade900],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: winnerPokemon == null
                        ? Colors.orange
                        : playerWon
                            ? Colors.green
                            : Colors.red,
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      winnerPokemon == null
                          ? Icons.handshake
                          : playerWon
                              ? Icons.emoji_events
                              : Icons.sentiment_dissatisfied,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      winnerPokemon == null
                          ? 'IT\'S A TIE!'
                          : playerWon
                              ? 'YOU WIN!'
                              : 'YOU LOSE!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (winnerPokemon != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${winnerPokemon!.name.toUpperCase()} wins with ${winnerPokemon!.stats.firstWhere(
                                (stat) => stat.name == 'attack',
                                orElse: () =>
                                    const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
                              ).baseStat} attack power!',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            // Battle Arena
            Expanded(
              child: Column(
                children: [
                  // Battle Labels
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'YOUR POKEMON',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        ' VS ',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'OPPONENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Pokemon Cards
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildPokemonCard(
                            playerPokemon,
                            'Your Pokemon',
                            isPlayer: true,
                            isWinner: winnerPokemon == playerPokemon,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPokemonCard(
                            opponentPokemon,
                            'Opponent',
                            isPlayer: false,
                            isWinner: winnerPokemon == opponentPokemon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Battle Button
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _startNewBattle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 24),
                label: const Text(
                  'New Battle (2 Random Pokemon)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonCard(
    PokemonCard? pokemon,
    String label, {
    required bool isPlayer,
    bool isWinner = false,
  }) {
    if (pokemon == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    final attackStat = pokemon.stats
        .firstWhere(
          (stat) => stat.name == 'attack',
          orElse: () => const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
        )
        .baseStat;

    Color borderColor = Colors.grey;
    if (battleComplete) {
      borderColor = isWinner ? Colors.green : Colors.red;
    } else if (isPlayer) {
      borderColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Column(
        children: [
          // Pokemon Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade800,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: pokemon.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Pokemon Name
          Text(
            pokemon.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Pokemon Types
          Wrap(
            spacing: 4,
            children: pokemon.types.map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTypeColor(type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          // Attack Stat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ATK: $attackStat',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow.shade700;
      case 'psychic':
        return Colors.purple;
      case 'ice':
        return Colors.cyan;
      case 'dragon':
        return Colors.indigo;
      case 'fighting':
        return Colors.red.shade700;
      case 'poison':
        return Colors.purple.shade700;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.blue.shade300;
      case 'bug':
        return Colors.green.shade700;
      case 'rock':
        return Colors.grey.shade600;
      case 'ghost':
        return Colors.purple.shade900;
      case 'steel':
        return Colors.grey.shade400;
      case 'fairy':
        return Colors.pink;
      case 'dark':
        return Colors.grey.shade800;
      case 'normal':
        return Colors.grey.shade500;
      default:
        return Colors.grey;
    }
  }
}
