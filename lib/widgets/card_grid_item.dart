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
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Background card image covering the entire container
              Positioned.fill(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10), // Slightly less than container to show border
                  child: _buildCardImage(),
                ),
              ),

              // Gradient overlay for text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.5, 0.8, 1.0],
                    ),
                  ),
                ),
              ),

              // Card information overlay at the bottom
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pokemon name
                    Text(
                      card.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      semanticsLabel: 'Pokémon name: ${card.name}',
                    ),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        // Pokédex number
                        if (card.pokedexNumber != null) ...[
                          Text(
                            '#${card.pokedexNumber}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            semanticsLabel: 'Pokédex number: ${card.pokedexNumber}',
                          ),
                          const Spacer(),
                        ],

                        // Types
                        if (card.types.isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              card.types.map((type) => type.toUpperCase()).join(', '),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              semanticsLabel: 'Pokemon types: ${card.types.join(', ')}',
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Primary ability
                    if (card.abilities.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        card.abilities.first.replaceAll('-', ' ').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        semanticsLabel: 'Primary ability: ${card.abilities.first}',
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
        height: double.infinity,
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
              Text('No Image', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: card.imageUrl,
      fit: BoxFit.cover, // Cover the entire container
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)),
        child: const Center(child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2)),
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
              Text('Load Error', style: TextStyle(color: Colors.red, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}
