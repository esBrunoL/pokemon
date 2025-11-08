import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/pokemon_card.dart';
import '../state/team_provider.dart';

class CardDetailDialog extends StatefulWidget {
  const CardDetailDialog({super.key, required this.card});
  final PokemonCard card;

  @override
  State<CardDetailDialog> createState() => _CardDetailDialogState();
}

class _CardDetailDialogState extends State<CardDetailDialog> {
  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        // Handle Escape key to close dialog
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.red.withAlpha(77), blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.red, width: 1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.card.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        semanticsLabel: 'Pokémon card details for ${widget.card.name}',
                      ),
                    ),
                    Semantics(
                      label: 'Close card details',
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Close',
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card image
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildCardImage(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Card information
                      _buildInfoSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage() {
    if (widget.card.imageUrl.isEmpty) {
      return Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: Colors.grey, size: 64),
              SizedBox(height: 16),
              Text('No Image Available', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.card.imageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(12)),
        child: const Center(child: CircularProgressIndicator(color: Colors.red)),
      ),
      errorWidget: (context, url, error) => Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text('Failed to Load Image', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Information',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Pokédex Number
        if (widget.card.pokedexNumber != null) ...[
          _buildInfoRow(
            'Pokédex Number',
            '#${widget.card.pokedexNumber}',
            Icons.numbers,
          ),
        ],

        // Height and Weight
        if (widget.card.height != null || widget.card.weight != null) ...[
          if (widget.card.height != null)
            _buildInfoRow(
              'Height',
              '${(widget.card.height! / 10).toStringAsFixed(1)} m',
              Icons.height,
            ),
          if (widget.card.weight != null)
            _buildInfoRow(
              'Weight',
              '${(widget.card.weight! / 10).toStringAsFixed(1)} kg',
              Icons.monitor_weight,
            ),
        ],

        // Base Experience
        if (widget.card.baseExperience != null) ...[
          _buildInfoRow(
            'Base Experience',
            '${widget.card.baseExperience}',
            Icons.star_rate,
          ),
        ],

        // Types
        if (widget.card.types.isNotEmpty) ...[
          _buildInfoRow(
            'Types',
            widget.card.types.map((type) => type.toUpperCase()).join(', '),
            Icons.category,
          ),
        ],

        // Abilities
        if (widget.card.abilities.isNotEmpty) ...[
          _buildInfoRow(
            'Abilities',
            widget.card.abilities
                .map((ability) => ability
                    .replaceAll('-', ' ')
                    .split(' ')
                    .map((word) =>
                        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word)
                    .join(' '))
                .join(', '),
            Icons.flash_on,
          ),
        ],

        // Stats
        if (widget.card.stats.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Stats',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.card.stats.map((stat) => _buildStatRow(stat.name, stat.baseStat, stat.effort)),
        ],

        const SizedBox(height: 24),

        // Action buttons
        Consumer<TeamProvider>(
          builder: (context, teamProvider, child) {
            final isInTeam = teamProvider.isPokemonInTeam(widget.card);
            final isFull = teamProvider.isFull;

            return Column(
              children: [
                // Add to Team Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isInTeam || (isFull && !isInTeam)
                        ? null
                        : () async {
                            final success = await teamProvider.addToTeam(widget.card);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? '${widget.card.name} added to your team!'
                                        : 'Failed to add ${widget.card.name} to team',
                                  ),
                                  backgroundColor: success ? Colors.green : Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInTeam ? Colors.grey : Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: Icon(isInTeam ? Icons.check_circle : Icons.add_circle),
                    label: Text(
                      isInTeam
                          ? 'Already in Team'
                          : (isFull
                              ? 'Team is Full (6/6)'
                              : 'Add to My Team (${teamProvider.teamSize}/6)'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Enter Tournament Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Tournament functionality to be implemented later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tournament feature coming soon!'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.emoji_events),
                    label: const Text(
                      'Enter a Tournament',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withAlpha(77)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red.withAlpha(178), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap outside or press Escape to close',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String statName, int baseStat, int effort) {
    // Format stat name for display
    String displayName = statName
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word)
        .join(' ');

    // Color coding for different stats
    Color statColor = Colors.white;
    switch (statName.toLowerCase()) {
      case 'hp':
        statColor = Colors.green;
        break;
      case 'attack':
        statColor = Colors.red;
        break;
      case 'defense':
        statColor = Colors.blue;
        break;
      case 'special-attack':
        statColor = Colors.purple;
        break;
      case 'special-defense':
        statColor = Colors.orange;
        break;
      case 'speed':
        statColor = Colors.yellow;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              displayName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: (baseStat / 255).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: statColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '$baseStat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (effort > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Text(
                'EV+$effort',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  semanticsLabel: '$label: $value',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
