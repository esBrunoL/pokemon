import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pokemon_card.dart';
import '../state/team_provider.dart';
import '../widgets/pokedex_frame_wrapper.dart';
import 'card_detail_screen.dart';
import 'gym_screen.dart';

class MyTeamScreen extends StatelessWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PokedexFrameWrapper(
      screenTitle: 'My Team',
      showSearch: false,
      child: Consumer<TeamProvider>(
        builder: (context, teamProvider, child) {
          if (teamProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          return Column(
            children: [
              // Tournament Entry Button at top
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  border: const Border(
                    bottom: BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: teamProvider.isEmpty
                      ? null
                      : () {
                          // Navigate to Gym Tournament
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GymScreen(),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  icon: const Icon(Icons.emoji_events, size: 28),
                  label: Text(
                    teamProvider.isEmpty
                        ? 'Add Pokemon to Enter Tournament'
                        : 'Enter a Tournament (${teamProvider.teamSize}/6)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Team members display
              Expanded(
                child: teamProvider.isEmpty
                    ? _buildEmptyState()
                    : _buildTeamGrid(context, teamProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 80,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            'Your team is empty',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add Pokemon from the Pokédex to build your team!',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamGrid(BuildContext context, TeamProvider teamProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: teamProvider.teamSize,
      itemBuilder: (context, index) {
        final pokemon = teamProvider.team[index];
        return _buildTeamMemberCard(context, pokemon, teamProvider);
      },
    );
  }

  Widget _buildTeamMemberCard(
    BuildContext context,
    PokemonCard pokemon,
    TeamProvider teamProvider,
  ) {
    return GestureDetector(
      onTap: () {
        // Show detail dialog when tapped
        showDialog(
          context: context,
          builder: (context) => CardDetailDialog(card: pokemon),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pokemon Image
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: pokemon.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: pokemon.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: Colors.red),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
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

            // Pokemon Info
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Pokedex Number
                  if (pokemon.pokedexNumber != null)
                    Text(
                      '#${pokemon.pokedexNumber}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Name
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

                  // Types
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
                ],
              ),
            ),

            // Remove Button
            Container(
              margin: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await _showRemoveConfirmation(context, pokemon);
                  if (confirmed == true) {
                    final removed = await teamProvider.removeFromTeam(pokemon);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            removed
                                ? '${pokemon.name} removed from team'
                                : 'Failed to remove ${pokemon.name}',
                          ),
                          backgroundColor: removed ? Colors.orange : Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.remove_circle, size: 16),
                label: const Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showRemoveConfirmation(BuildContext context, PokemonCard pokemon) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        title: const Text(
          'Remove from Team?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${pokemon.name} from your team?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
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
