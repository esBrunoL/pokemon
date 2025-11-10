import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon_card.dart';
import '../services/api_service.dart';
import '../state/team_provider.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  List<PokemonCard> opponentTeam = [];
  PokemonCard? selectedPlayerPokemon;
  PokemonCard? currentOpponentPokemon;
  PokemonCard? winnerPokemon;
  bool isLoading = false;
  String? errorMessage;
  bool battleComplete = false;
  int currentOpponentIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateOpponentTeam();
  }

  Future<void> _generateOpponentTeam() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiService = PokemonApiService();
      final List<PokemonCard> team = [];
      
      for (int i = 0; i < 6; i++) {
        final randomId = Random().nextInt(1008) + 1;
        final pokemon = await apiService.getPokemonById(randomId.toString());
        if (pokemon != null) {
          team.add(pokemon);
        }
      }
      
      setState(() {
        opponentTeam = team;
        currentOpponentPokemon = team.isNotEmpty ? team[0] : null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error generating opponent team: $e';
        isLoading = false;
      });
    }
  }

  void _selectPlayerPokemon(PokemonCard pokemon) {
    setState(() {
      selectedPlayerPokemon = pokemon;
      battleComplete = false;
      winnerPokemon = null;
    });
  }

  void _performBattle() {
    if (selectedPlayerPokemon != null && currentOpponentPokemon != null) {
      final playerAttack = selectedPlayerPokemon!.stats.firstWhere(
        (stat) => stat.name == 'attack',
        orElse: () => const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
      ).baseStat;
      
      final opponentAttack = currentOpponentPokemon!.stats.firstWhere(
        (stat) => stat.name == 'attack',
        orElse: () => const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
      ).baseStat;

      setState(() {
        if (playerAttack > opponentAttack) {
          winnerPokemon = selectedPlayerPokemon;
        } else if (opponentAttack > playerAttack) {
          winnerPokemon = currentOpponentPokemon;
        } else {
          winnerPokemon = Random().nextBool() ? selectedPlayerPokemon : currentOpponentPokemon;
        }
        battleComplete = true;
      });

      // Move to next opponent if player wins
      if (winnerPokemon == selectedPlayerPokemon) {
        Future.delayed(const Duration(seconds: 2), () {
          if (currentOpponentIndex < opponentTeam.length - 1) {
            setState(() {
              currentOpponentIndex++;
              currentOpponentPokemon = opponentTeam[currentOpponentIndex];
              battleComplete = false;
              winnerPokemon = null;
              selectedPlayerPokemon = null;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final playerTeam = teamProvider.team;
    final playerWon = winnerPokemon == selectedPlayerPokemon;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Gym Challenge',
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

            // Battle result
            if (battleComplete && winnerPokemon != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: playerWon
                        ? [Colors.green.shade700, Colors.green.shade900]
                        : [Colors.red.shade700, Colors.red.shade900],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: playerWon ? Colors.green : Colors.red,
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      playerWon ? Icons.emoji_events : Icons.close,
                      color: Colors.yellow,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      playerWon
                          ? '${selectedPlayerPokemon!.name.toUpperCase()} WINS!'
                          : '${selectedPlayerPokemon!.name.toUpperCase()} LOST!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (playerWon && currentOpponentIndex < opponentTeam.length - 1)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Next opponent incoming...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Team grids and battle area
            Expanded(
              child: Row(
                children: [
                  // Player team (left side)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'MY TEAM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _buildPlayerTeamGrid(playerTeam),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Battle area (center)
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // Battle cards
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildBattlePokemonCard(
                                  selectedPlayerPokemon,
                                  'SELECTED',
                                  isPlayer: true,
                                  isWinner: winnerPokemon == selectedPlayerPokemon,
                                ),
                              ),
                              
                              const SizedBox(width: 16),

                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade800,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Text(
                                  'VS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: _buildBattlePokemonCard(
                                  currentOpponentPokemon,
                                  'OPPONENT ${currentOpponentIndex + 1}/6',
                                  isPlayer: false,
                                  isWinner: winnerPokemon == currentOpponentPokemon,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Battle button
                        if (selectedPlayerPokemon != null && !battleComplete)
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton.icon(
                              onPressed: _performBattle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              icon: const Icon(Icons.flash_on, size: 28),
                              label: const Text(
                                'BATTLE!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Opponent team (right side)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'GYM TEAM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _buildOpponentTeamGrid(),
                        ),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildPlayerTeamGrid(List<PokemonCard> team) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6, // Always show 6 slots
      itemBuilder: (context, index) {
        final pokemon = index < team.length ? team[index] : null;
        final isSelected = pokemon == selectedPlayerPokemon;
        
        return GestureDetector(
          onTap: pokemon != null ? () => _selectPlayerPokemon(pokemon) : null,
          child: Container(
            decoration: BoxDecoration(
              color: pokemon != null 
                  ? (isSelected ? Colors.blue.shade700 : Colors.grey.shade800)
                  : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: pokemon != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: pokemon.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildOpponentTeamGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final pokemon = index < opponentTeam.length ? opponentTeam[index] : null;
        final isCurrent = index == currentOpponentIndex;
        final isDefeated = index < currentOpponentIndex;
        
        return Container(
          decoration: BoxDecoration(
            color: isCurrent 
                ? Colors.red.shade700 
                : isDefeated 
                    ? Colors.grey.shade700 
                    : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent ? Colors.red : Colors.grey,
              width: isCurrent ? 3 : 1,
            ),
          ),
          child: pokemon != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isDefeated)
                      const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 32,
                      )
                    else if (pokemon.types.isNotEmpty)
                      ...pokemon.types.map((type) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )).take(2),
                    if (isCurrent)
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Icon(
                          Icons.flash_on,
                          color: Colors.yellow,
                          size: 16,
                        ),
                      ),
                  ],
                )
              : const Center(
                  child: Icon(
                    Icons.help_outline,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBattlePokemonCard(
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
        child: Center(
          child: Text(
            isPlayer ? 'Select a Pokemon' : 'Loading...',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final attackStat = pokemon.stats.firstWhere(
      (stat) => stat.name == 'attack',
      orElse: () => const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
    ).baseStat;

    Color borderColor = Colors.grey;
    if (battleComplete) {
      borderColor = isWinner ? Colors.green : Colors.red;
    } else if (isPlayer) {
      borderColor = Colors.blue;
    } else {
      borderColor = Colors.red.shade600;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: pokemon.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: pokemon.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.red, size: 50),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                    ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                if (pokemon.pokedexNumber != null)
                  Text(
                    '#${pokemon.pokedexNumber}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 4),

                Text(
                  pokemon.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                if (pokemon.types.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    alignment: WrapAlignment.center,
                    children: pokemon.types.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
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
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(pokemon.types.isNotEmpty ? pokemon.types.first : 'normal'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flash_on, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'ATK: $attackStat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        return Colors.yellow;
      case 'psychic':
        return Colors.purple;
      case 'ice':
        return Colors.cyan;
      case 'dragon':
        return Colors.indigo;
      case 'dark':
        return Colors.brown;
      case 'fairy':
        return Colors.pink;
      case 'normal':
        return Colors.grey;
      case 'fighting':
        return Colors.red.shade900;
      case 'flying':
        return Colors.lightBlue;
      case 'poison':
        return Colors.deepPurple;
      case 'ground':
        return Colors.brown.shade700;
      case 'rock':
        return Colors.grey.shade700;
      case 'bug':
        return Colors.lightGreen;
      case 'ghost':
        return Colors.deepPurple.shade900;
      case 'steel':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}