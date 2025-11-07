import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pokemon_card.dart';

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
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
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
              BoxShadow(
                  color: Colors.red.withAlpha(77),
                  blurRadius: 20,
                  spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.red, width: 1)),
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
                        semanticsLabel:
                            'Pokémon card details for ${widget.card.name}',
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
                          constraints: const BoxConstraints(
                              maxWidth: 300, maxHeight: 400),
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
              Text('No Image Available',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
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
        decoration: BoxDecoration(
            color: Colors.grey[800], borderRadius: BorderRadius.circular(12)),
        child:
            const Center(child: CircularProgressIndicator(color: Colors.red)),
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
              Text('Failed to Load Image',
                  style: TextStyle(color: Colors.red, fontSize: 16)),
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
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // National Pokédex Numbers
        if (widget.card.nationalPokedexNumbers.isNotEmpty) ...[
          _buildInfoRow(
            'Pokédex Number',
            '#${widget.card.nationalPokedexNumbers.join(', #')}',
            Icons.numbers,
          ),
        ],

        // Set
        if (widget.card.setName != null) ...[
          _buildInfoRow(
              'Set', widget.card.setName!, Icons.collections_bookmark),
        ],

        // Rarity
        if (widget.card.rarity != null) ...[
          _buildInfoRow('Rarity', widget.card.rarity!, Icons.star),
        ],

        // Supertype
        if (widget.card.supertype != null) ...[
          _buildInfoRow('Type', widget.card.supertype!, Icons.category),
        ],

        // Subtypes
        if (widget.card.subtypes != null) ...[
          _buildInfoRow('Subtypes', widget.card.subtypes!, Icons.label),
        ],

        // Evolution information
        if (widget.card.evolvesFrom != null) ...[
          _buildInfoRow(
              'Evolves From', widget.card.evolvesFrom!, Icons.trending_up),
        ],

        if (widget.card.evolvesTo.isNotEmpty) ...[
          _buildInfoRow('Evolves To', widget.card.evolvesTo.join(', '),
              Icons.trending_up),
        ],

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
              Icon(Icons.info_outline,
                  color: Colors.red.withAlpha(178), size: 16),
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
