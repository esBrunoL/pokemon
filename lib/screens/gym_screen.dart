import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon_card.dart';
import '../services/api_service.dart';
import '../state/team_provider.dart';
import '../widgets/pokedex_frame_wrapper.dart';

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
  Set<String> defeatedPlayerPokemonIds = {}; // Track defeated player Pokemon

  // Responsive layout state
  bool _isLeftPanelExpanded = false;
  bool _isRightPanelExpanded = false;
  bool _isLeftPanelLocked = false;
  bool _isRightPanelLocked = false;

  // Layout constants
  static const double centerContainerWidth = 500.0;
  static const double sidePanelCollapsedWidth = 60.0;
  static const double sidePanelExpandedWidth = 200.0;
  static const double minimumScreenWidth = centerContainerWidth + (sidePanelCollapsedWidth * 2);
  static const double largeScreenThreshold = 1200.0; // Use old layout above this width

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
    // Prevent selecting defeated Pokemon
    if (defeatedPlayerPokemonIds.contains(pokemon.id)) {
      return;
    }

    setState(() {
      selectedPlayerPokemon = pokemon;
      battleComplete = false;
      winnerPokemon = null;
    });
  }

  void _performBattle() {
    if (selectedPlayerPokemon != null && currentOpponentPokemon != null) {
      final playerAttack = selectedPlayerPokemon!.stats
          .firstWhere(
            (stat) => stat.name == 'attack',
            orElse: () => const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
          )
          .baseStat;

      final opponentAttack = currentOpponentPokemon!.stats
          .firstWhere(
            (stat) => stat.name == 'attack',
            orElse: () => const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
          )
          .baseStat;

      setState(() {
        if (playerAttack > opponentAttack) {
          winnerPokemon = selectedPlayerPokemon;
        } else if (opponentAttack > playerAttack) {
          winnerPokemon = currentOpponentPokemon;
        } else {
          // Draw - both Pokemon are considered defeated
          winnerPokemon = null; // No winner in case of draw
        }
        battleComplete = true;
      });

      // Handle Pokemon defeat
      if (winnerPokemon == currentOpponentPokemon && selectedPlayerPokemon != null) {
        // Player's Pokemon is defeated - mark it as unavailable
        setState(() {
          defeatedPlayerPokemonIds.add(selectedPlayerPokemon!.id);
        });
      } else if (winnerPokemon == null) {
        // Draw - both Pokemon are defeated
        setState(() {
          defeatedPlayerPokemonIds.add(selectedPlayerPokemon!.id);
        });
      }

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
    final playerWon = winnerPokemon == selectedPlayerPokemon;

    return PokedexFrameWrapper(
      screenTitle: 'Gym Challenge',
      showSearch: false,
      child: Padding(
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
            if (battleComplete)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: winnerPokemon == null
                        ? [Colors.orange.shade700, Colors.orange.shade900] // Draw
                        : playerWon
                            ? [Colors.green.shade700, Colors.green.shade900] // Player wins
                            : [Colors.red.shade700, Colors.red.shade900], // Player loses
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: winnerPokemon == null
                        ? Colors.orange // Draw
                        : playerWon
                            ? Colors.green // Player wins
                            : Colors.red, // Player loses
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      winnerPokemon == null
                          ? Icons.handshake // Draw
                          : playerWon
                              ? Icons.emoji_events // Player wins
                              : Icons.close, // Player loses
                      color: Colors.yellow,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      winnerPokemon == null
                          ? 'DRAW! BOTH POKÉMON DEFEATED!'
                          : playerWon
                              ? '${selectedPlayerPokemon!.name.toUpperCase()} WINS!'
                              : '${selectedPlayerPokemon!.name.toUpperCase()} LOST!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (winnerPokemon == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Equal attack power means both Pokémon are defeated!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

            // Team grids and battle area - Responsive Layout
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _buildResponsiveLayout(context, teamProvider, constraints);
                },
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
        final isDefeated = pokemon != null && defeatedPlayerPokemonIds.contains(pokemon.id);

        return GestureDetector(
          onTap: pokemon != null && !isDefeated ? () => _selectPlayerPokemon(pokemon) : null,
          child: Container(
            decoration: BoxDecoration(
              color: pokemon != null
                  ? (isSelected ? Colors.blue.shade700 : Colors.grey.shade800)
                  : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue : (isDefeated ? Colors.red.shade600 : Colors.grey),
                width: isSelected ? 3 : 1,
              ),
            ),
            child: pokemon != null
                ? Stack(
                    children: [
                      ClipRRect(
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
                      ),
                      // Gray mask for defeated Pokemon
                      if (isDefeated)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 32,
                                ),
                                Text(
                                  'DEFEATED',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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
                      ...pokemon.types
                          .map((type) => Container(
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
                              ))
                          .take(2),
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

  // New responsive layout method
  Widget _buildResponsiveLayout(
      BuildContext context, TeamProvider teamProvider, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final isLargeScreen = screenWidth >= largeScreenThreshold;
    final isSmallScreen = screenWidth < minimumScreenWidth;

    // Use old layout for large screens
    if (isLargeScreen) {
      return _buildClassicLayout(teamProvider);
    }

    // Use responsive layout for smaller screens
    final availableWidth = screenWidth - 32; // Account for padding

    // Calculate center container width
    final centerWidth = isSmallScreen
        ? availableWidth - (sidePanelCollapsedWidth * 2)
        : centerContainerWidth.clamp(300.0, availableWidth - (sidePanelCollapsedWidth * 2));

    return Column(
      children: [
        // Warning message for small screens
        if (isSmallScreen) _buildScreenSizeWarning(),

        // Main layout with overlay support
        Expanded(
          child: Stack(
            children: [
              Row(
                children: [
                  // Left panel (Player team)
                  _buildSidePanel(
                    isLeft: true,
                    isExpanded: _isLeftPanelExpanded,
                    isLocked: _isLeftPanelLocked,
                    title: 'MY TEAM',
                    color: Colors.blue.shade800,
                    child: _buildPlayerTeamGrid(teamProvider.team),
                  ),

                  // Center container (Battle area)
                  Container(
                    width: centerWidth,
                    child: _buildCenterBattleArea(),
                  ),

                  // Right panel (Opponent team)
                  _buildSidePanel(
                    isLeft: false,
                    isExpanded: _isRightPanelExpanded,
                    isLocked: _isRightPanelLocked,
                    title: 'GYM TEAM',
                    color: Colors.red.shade800,
                    child: _buildOpponentTeamGrid(),
                  ),
                ],
              ),

              // Overlay expansions for teams
              if (_isLeftPanelExpanded && !_isLeftPanelLocked)
                _buildTeamOverlay(true, teamProvider.team),
              if (_isRightPanelExpanded && !_isRightPanelLocked) _buildTeamOverlay(false, null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScreenSizeWarning() {
    final recommendedWidth = minimumScreenWidth.toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'To improve your battle experience, enlarge the screen to at least $recommendedWidth pixels wide. Current layout is optimized for larger displays.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel({
    required bool isLeft,
    required bool isExpanded,
    required bool isLocked,
    required String title,
    required Color color,
    required Widget child,
  }) {
    final panelWidth = isExpanded || isLocked ? sidePanelExpandedWidth : sidePanelCollapsedWidth;

    return MouseRegion(
      onEnter: (_) {
        if (!isLocked) {
          setState(() {
            if (isLeft) {
              _isLeftPanelExpanded = true;
            } else {
              _isRightPanelExpanded = true;
            }
          });
        }
      },
      onExit: (_) {
        if (!isLocked) {
          setState(() {
            if (isLeft) {
              _isLeftPanelExpanded = false;
            } else {
              _isRightPanelExpanded = false;
            }
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isLeft) {
              _isLeftPanelLocked = !_isLeftPanelLocked;
              if (_isLeftPanelLocked) {
                _isLeftPanelExpanded = true;
              }
            } else {
              _isRightPanelLocked = !_isRightPanelLocked;
              if (_isRightPanelLocked) {
                _isRightPanelExpanded = true;
              }
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: panelWidth,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLocked ? Colors.orange : color,
              width: isLocked ? 3 : 1,
            ),
          ),
          child: Column(
            children: [
              // Panel header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.orange.shade800 : color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isExpanded || isLocked)
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      Icon(
                        isLeft ? Icons.group : Icons.sports_martial_arts,
                        color: Colors.white,
                        size: 16,
                      ),
                    if (isLocked)
                      const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 14,
                      ),
                  ],
                ),
              ),

              // Panel content
              if (isExpanded || isLocked)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: child,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterBattleArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 2),
      ),
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
              height: 50,
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
                icon: const Icon(Icons.flash_on, size: 24),
                label: const Text(
                  'BATTLE!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Classic layout for large screens (original layout)
  Widget _buildClassicLayout(TeamProvider teamProvider) {
    return Row(
      children: [
        // Player team (left side)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'MY TEAM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildPlayerTeamGrid(teamProvider.team),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Battle area (center)
        Container(
          width: 400,
          child: _buildCenterBattleArea(),
        ),

        const SizedBox(width: 16),

        // Opponent team (right side)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'GYM TEAM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildOpponentTeamGrid(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Team overlay that expands to center when panels are hovered but not locked
  Widget _buildTeamOverlay(bool isPlayerTeam, List<PokemonCard>? playerTeam) {
    return Positioned(
      left: 60, // Start after collapsed panel
      right: 60, // End before collapsed panel on right
      top: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlayerTeam ? Colors.blue : Colors.red,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            // Overlay header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPlayerTeam ? Colors.blue.shade800 : Colors.red.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                ),
              ),
              child: Text(
                isPlayerTeam ? 'MY TEAM - DETAILED VIEW' : 'GYM TEAM - DETAILED VIEW',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Expanded team grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isPlayerTeam && playerTeam != null
                    ? _buildExpandedPlayerTeamGrid(playerTeam)
                    : _buildExpandedOpponentTeamGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPlayerTeamGrid(List<PokemonCard> team) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // More columns for overlay view
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6, // Always show 6 slots
      itemBuilder: (context, index) {
        final pokemon = index < team.length ? team[index] : null;
        final isSelected = pokemon == selectedPlayerPokemon;
        final isDefeated = pokemon != null && defeatedPlayerPokemonIds.contains(pokemon.id);

        return GestureDetector(
          onTap: pokemon != null && !isDefeated ? () => _selectPlayerPokemon(pokemon) : null,
          child: Container(
            decoration: BoxDecoration(
              color: pokemon != null
                  ? (isSelected ? Colors.blue.shade700 : Colors.grey.shade800)
                  : Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : (isDefeated ? Colors.red.shade600 : Colors.grey),
                width: isSelected ? 3 : 1,
              ),
            ),
            child: pokemon != null
                ? Stack(
                    children: [
                      Column(
                        children: [
                          // Pokemon image
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: pokemon.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(color: Colors.red),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                          // Pokemon info
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (pokemon.pokedexNumber != null)
                                    Text(
                                      '#${pokemon.pokedexNumber}',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pokemon.name.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (pokemon.types.isNotEmpty)
                                    Wrap(
                                      spacing: 2,
                                      alignment: WrapAlignment.center,
                                      children: pokemon.types.take(2).map((type) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getTypeColor(type),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            type.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Gray mask for defeated Pokemon
                      if (isDefeated)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                Text(
                                  'DEFEATED',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.grey,
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'EMPTY SLOT',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedOpponentTeamGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // More columns for overlay view
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent ? Colors.red : Colors.grey,
              width: isCurrent ? 3 : 1,
            ),
          ),
          child: pokemon != null
              ? Column(
                  children: [
                    // Pokemon image
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: isDefeated
                            ? Container(
                                color: Colors.black.withOpacity(0.7),
                                child: const Center(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _getTypeColor(pokemon.types.isNotEmpty
                                          ? pokemon.types.first
                                          : 'normal'),
                                      _getTypeColor(pokemon.types.length > 1
                                          ? pokemon.types[1]
                                          : pokemon.types.first),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.help_outline,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 60,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Pokemon info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isDefeated)
                              const Text(
                                'DEFEATED',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else ...[
                              Text(
                                isCurrent ? 'CURRENT' : 'WAITING',
                                style: TextStyle(
                                  color: isCurrent ? Colors.yellow : Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (pokemon.types.isNotEmpty)
                                Wrap(
                                  spacing: 2,
                                  alignment: WrapAlignment.center,
                                  children: pokemon.types.take(2).map((type) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(type),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        type.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.grey,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'UNKNOWN',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
