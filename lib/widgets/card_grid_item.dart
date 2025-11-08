import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/pokemon_card.dart';

class CardGridItem extends StatelessWidget {
  const CardGridItem({super.key, required this.card, required this.onTap});
  final PokemonCard card;
  final VoidCallback onTap;

  /// Get color for Pokemon type
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

  /// Get attack stat value
  int get _attackStat {
    final attackStat = card.stats.firstWhere(
      (stat) => stat.name == 'attack',
      orElse: () => const PokemonStat(name: 'attack', baseStat: 0, effort: 0),
    );
    return attackStat.baseStat;
  }

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
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pokédex number
                      if (card.pokedexNumber != null)
                        Text(
                          '#${card.pokedexNumber}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black,
                              ),
                            ],
                          ),
                          semanticsLabel: 'Pokédex number: ${card.pokedexNumber}',
                        ),
                      const SizedBox(height: 4),

                      // Pokemon name
                      Text(
                        card.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        semanticsLabel: 'Pokémon name: ${card.name}',
                      ),

                      const SizedBox(height: 6),

                      // Types
                      if (card.types.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          alignment: WrapAlignment.center,
                          children: card.types.map((type) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor(type),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 8),

                      // Attack stat at bottom with type color
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              card.types.isNotEmpty ? _getTypeColor(card.types.first) : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ATK: $_attackStat',
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
                            ),
                          ],
                        ),
                      ),
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
