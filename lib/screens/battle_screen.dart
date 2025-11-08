import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon_card.dart';
import '../models/type_effectiveness.dart';
import '../services/api_service.dart';
import '../state/team_provider.dart';
import 'card_detail_screen.dart';
import 'my_team_screen.dart';

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
  TypeEffectivenessCalculator? _typeCalculator;
  String playerEffectivenessMessage = '';
  String opponentEffectivenessMessage = '';
  int effectivePlayerAttack = 0;
  int effectiveOpponentAttack = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    // If no Pokemon provided, load two random Pokemon for battle
    if (playerPokemon == null && opponentPokemon == null) {
      if (args is PokemonCard) {
        setState(() {
          playerPokemon = args;
        });
        _loadRandomOpponent();
      } else {
        // No argument provided - load TWO random Pokemon
        _loadRandomBattle();
      }
    }
  }

  Future<void> _loadRandomBattle() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      battleComplete = false;
      winnerPokemon = null;
      playerPokemon = null;
      opponentPokemon = null;
    });

    try {
      final apiService = context.read<PokemonApiService>();

      // Load two different random Pokemon
      final randomId1 = Random().nextInt(1008) + 1;
      int randomId2 = Random().nextInt(1008) + 1;

      // Ensure they're different
      while (randomId2 == randomId1) {
        randomId2 = Random().nextInt(1008) + 1;
      }

      final player = await apiService.getPokemonById(randomId1.toString());
      final opponent = await apiService.getPokemonById(randomId2.toString());

      if (player != null && opponent != null) {
        setState(() {
          playerPokemon = player;
          opponentPokemon = opponent;
          isLoading = false;
        });
        _performBattle();
      } else {
        setState(() {
          errorMessage = 'Could not fetch Pokemon for battle';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading battle: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadRandomOpponent() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      battleComplete = false;
      winnerPokemon = null;
    });

    try {
      final apiService = context.read<PokemonApiService>();
      final randomId = Random().nextInt(1008) + 1;
      final opponent = await apiService.getPokemonById(randomId.toString());

      if (opponent != null) {
        setState(() {
          opponentPokemon = opponent;
          isLoading = false;
        });
        _performBattle();
      } else {
        setState(() {
          errorMessage = 'Could not fetch opponent Pokemon';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading opponent: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _performBattle() async {
    if (playerPokemon == null || opponentPokemon == null) return;

    // Initialize type effectiveness calculator if not already done
    if (_typeCalculator == null) {
      try {
        final apiService = context.read<PokemonApiService>();
        _typeCalculator = await apiService.getTypeEffectivenessCalculator();
      } catch (e) {
        debugPrint('Error loading type effectiveness: $e');
        // Continue without type effectiveness
      }
    }

    // Get base attack stats
    final playerBaseAttack = _getAttackStat(playerPokemon!);
    final opponentBaseAttack = _getAttackStat(opponentPokemon!);

    // Apply type effectiveness multipliers
    int playerAttack = playerBaseAttack;
    int opponentAttack = opponentBaseAttack;
    String playerMsg = '';
    String opponentMsg = '';

    if (_typeCalculator != null) {
      playerAttack = _typeCalculator!.calculateEffectiveAttack(
        playerBaseAttack,
        playerPokemon!.types,
        opponentPokemon!.types,
      );
      opponentAttack = _typeCalculator!.calculateEffectiveAttack(
        opponentBaseAttack,
        opponentPokemon!.types,
        playerPokemon!.types,
      );

      playerMsg = _typeCalculator!.getEffectivenessMessage(
        playerPokemon!.types,
        opponentPokemon!.types,
      );
      opponentMsg = _typeCalculator!.getEffectivenessMessage(
        opponentPokemon!.types,
        playerPokemon!.types,
      );
    }

    // Get HP stats
    final playerHP = playerPokemon!.hp;
    final opponentHP = opponentPokemon!.hp;

    // Battle logic: Attack vs HP
    final playerKillsOpponent = playerAttack > opponentHP;
    final opponentKillsPlayer = opponentAttack > playerHP;

    setState(() {
      effectivePlayerAttack = playerAttack;
      effectiveOpponentAttack = opponentAttack;
      playerEffectivenessMessage = playerMsg;
      opponentEffectivenessMessage = opponentMsg;

      if (playerKillsOpponent && !opponentKillsPlayer) {
        // Player wins: can kill opponent and survives
        winnerPokemon = playerPokemon;
      } else if (opponentKillsPlayer && !playerKillsOpponent) {
        // Opponent wins: can kill player and survives
        winnerPokemon = opponentPokemon;
      } else if (playerKillsOpponent && opponentKillsPlayer) {
        // Draw: both can kill each other
        winnerPokemon = null;
      } else {
        // Neither can kill: winner is the one with higher effective attack
        winnerPokemon = playerAttack >= opponentAttack ? playerPokemon : opponentPokemon;
      }
      battleComplete = true;
    });
  }

  int _getAttackStat(PokemonCard pokemon) {
    return pokemon.stats
        .firstWhere(
          (stat) => stat.name == 'attack',
          orElse: () => const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
        )
        .baseStat;
  }

  @override
  Widget build(BuildContext context) {
    final playerWon = winnerPokemon == playerPokemon;
    final screenSize = MediaQuery.of(context).size;
    final borderWidth = screenSize.width * 0.02;

    return Scaffold(
      backgroundColor: Colors.red,
      body: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Menu bar at top
            Container(
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    // Title
                    const Text(
                      'Try outs!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Home Button
                    Semantics(
                      label: 'Home',
                      child: IconButton(
                        icon: const Icon(
                          Icons.home,
                          color: Colors.black,
                          size: 28,
                          weight: 700,
                        ),
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Battle Simulator Button (disabled - already on this screen)
                    Semantics(
                      label: 'Battle Simulator (Current Screen)',
                      child: IconButton(
                        icon: Icon(
                          Icons.flash_on,
                          color: Colors.grey.withOpacity(0.4),
                          size: 28,
                          weight: 700,
                        ),
                        onPressed: null, // Disabled - already on battle screen
                      ),
                    ),
                    const SizedBox(width: 8),
                    // My Team Button
                    Consumer<TeamProvider>(
                      builder: (context, teamProvider, child) {
                        final teamSize = teamProvider.teamSize;
                        return Stack(
                          children: [
                            Semantics(
                              label: 'My Team ($teamSize/6 Pokemon)',
                              child: IconButton(
                                icon: const Icon(
                                  Icons.group,
                                  color: Colors.black,
                                  size: 28,
                                  weight: 700,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MyTeamScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (teamSize > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 1),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    '$teamSize',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Battle content
            Expanded(
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
                                  ? Icons.balance
                                  : playerWon
                                      ? Icons.emoji_events
                                      : Icons.close,
                              color: Colors.yellow,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              winnerPokemon == null
                                  ? 'DRAW! Both defeated!'
                                  : playerWon
                                      ? '${playerPokemon!.name.toUpperCase()} WINS!'
                                      : '${playerPokemon!.name.toUpperCase()} LOST!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (playerPokemon != null && opponentPokemon != null) ...[
                              const SizedBox(height: 8),
                              // Battle stats
                              Text(
                                '${playerPokemon!.name}: ATK ${effectivePlayerAttack > 0 ? effectivePlayerAttack : _getAttackStat(playerPokemon!)} vs HP ${opponentPokemon!.hp}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '${opponentPokemon!.name}: ATK ${effectiveOpponentAttack > 0 ? effectiveOpponentAttack : _getAttackStat(opponentPokemon!)} vs HP ${playerPokemon!.hp}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                // Player effectiveness message
                                if (battleComplete && playerEffectivenessMessage.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: playerEffectivenessMessage.contains('super effective')
                                          ? Colors.green.withOpacity(0.8)
                                          : playerEffectivenessMessage
                                                  .contains('not very effective')
                                              ? Colors.red.withOpacity(0.8)
                                              : Colors.grey.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      playerEffectivenessMessage,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                Expanded(
                                  child: _buildPokemonCard(
                                    playerPokemon,
                                    'ON TRIAL',
                                    isPlayer: true,
                                    isWinner: winnerPokemon == playerPokemon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // VS badge
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Container(
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
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                // Opponent effectiveness message
                                if (battleComplete && opponentEffectivenessMessage.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color:
                                          opponentEffectivenessMessage.contains('super effective')
                                              ? Colors.green.withOpacity(0.8)
                                              : opponentEffectivenessMessage
                                                      .contains('not very effective')
                                                  ? Colors.red.withOpacity(0.8)
                                                  : Colors.grey.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      opponentEffectivenessMessage,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                Expanded(
                                  child: _buildPokemonCard(
                                    opponentPokemon,
                                    'OPPONENT',
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
                    const SizedBox(height: 16),
                    if (battleComplete)
                      Row(
                        children: [
                          // Try out player Pokemon button
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    // Keep player Pokemon, get new opponent
                                    battleComplete = false;
                                    winnerPokemon = null;
                                  });
                                  _loadRandomOpponent();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: winnerPokemon == playerPokemon
                                      ? Colors.green
                                      : winnerPokemon == opponentPokemon
                                          ? Colors.red
                                          : Colors.orange, // Draw case
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                icon: Icon(
                                  winnerPokemon == playerPokemon
                                      ? Icons.emoji_events
                                      : Icons.person,
                                  size: 20,
                                ),
                                label: Text(
                                  'Try ${playerPokemon?.name ?? "this"}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Try out opponent Pokemon button
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    // Switch: opponent becomes player
                                    playerPokemon = opponentPokemon;
                                    battleComplete = false;
                                    winnerPokemon = null;
                                  });
                                  _loadRandomOpponent();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: winnerPokemon == opponentPokemon
                                      ? Colors.green
                                      : winnerPokemon == playerPokemon
                                          ? Colors.red
                                          : Colors.orange, // Draw case
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                icon: Icon(
                                  winnerPokemon == opponentPokemon
                                      ? Icons.emoji_events
                                      : Icons.swap_horiz,
                                  size: 20,
                                ),
                                label: Text(
                                  'Try ${opponentPokemon?.name ?? "this"}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    if (battleComplete)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _loadRandomBattle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
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

    return GestureDetector(
      onTap: () {
        // Show Pokemon details when tapped
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => CardDetailDialog(card: pokemon),
        );
      },
      child: Container(
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
                      color:
                          _getTypeColor(pokemon.types.isNotEmpty ? pokemon.types.first : 'normal'),
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
