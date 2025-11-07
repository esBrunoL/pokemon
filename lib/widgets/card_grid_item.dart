import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/pokemon_card.dart';

class CardGridItem extends StatelessWidget {
  const CardGridItem({super.key, required this.card, required this.onTap});
  final PokemonCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card image (as button)
              Expanded(
                flex: 3,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildCardImage(),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Card information
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pokemon name
                    Text(
                      card.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      semanticsLabel: 'Pokémon name: ${card.name}',
                    ),

                    const SizedBox(height: 4),

                    // Set name
                    if (card.setName != null) ...[
                      Text(
                        'Set: ${card.setName}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        semanticsLabel: 'Card set: ${card.setName}',
                      ),
                    ],

                    // Rarity
                    if (card.rarity != null) ...[
                      Text(
                        card.rarity!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        semanticsLabel: 'Card rarity: ${card.rarity}',
                      ),
                    ],

                    // National Pokédex number
                    if (card.nationalPokedexNumbers.isNotEmpty) ...[
                      Text(
                        '#${card.nationalPokedexNumbers.first}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                        semanticsLabel:
                            'Pokédex number: ${card.nationalPokedexNumbers.first}',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage() {
    if (card.imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: Colors.grey, size: 32),
              SizedBox(height: 4),
              Text('No Image',
                  style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: card.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(
            color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
        child: const Center(
            child:
                CircularProgressIndicator(color: Colors.red, strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 1),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 32),
              SizedBox(height: 4),
              Text('Load Error',
                  style: TextStyle(color: Colors.red, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
