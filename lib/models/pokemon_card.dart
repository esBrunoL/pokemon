class PokemonCard {
  const PokemonCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.height,
    this.weight,
    this.baseExperience,
    this.order,
    this.types = const [],
    this.abilities = const [],
    this.stats = const [],
    this.pokedexNumber,
  });

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    return PokemonCard(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['sprites']?['other']?['official-artwork']?['front_default'] ??
          json['sprites']?['other']?['home']?['front_default'] ??
          json['sprites']?['front_default'] ??
          '',
      height: json['height'],
      weight: json['weight'],
      baseExperience: json['base_experience'],
      order: json['order'],
      types: _parseTypes(json['types']),
      abilities: _parseAbilities(json['abilities']),
      stats: _parseStats(json['stats']),
      pokedexNumber: json['id'],
    );
  }

  final String id;
  final String name;
  final String imageUrl;
  final int? height;
  final int? weight;
  final int? baseExperience;
  final int? order;
  final List<String> types;
  final List<String> abilities;
  final List<PokemonStat> stats;
  final int? pokedexNumber;

  /// Convert PokemonCard to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? 0,
      'name': name,
      'sprites': {
        'front_default': imageUrl,
        'other': {
          'official-artwork': {
            'front_default': imageUrl,
          }
        }
      },
      'height': height,
      'weight': weight,
      'base_experience': baseExperience,
      'order': order,
      'types': types
          .map((type) => {
                'type': {'name': type}
              })
          .toList(),
      'abilities': abilities
          .map((ability) => {
                'ability': {'name': ability}
              })
          .toList(),
      'stats': stats.map((stat) => stat.toJson()).toList(),
    };
  }

  /// Helper method to parse types from JSON
  static List<String> _parseTypes(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => e?['type']?['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Helper method to parse abilities from JSON
  static List<String> _parseAbilities(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => e?['ability']?['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Helper method to parse stats from JSON
  static List<PokemonStat> _parseStats(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) {
            if (e is Map<String, dynamic>) {
              return PokemonStat.fromJson(e);
            }
            return null;
          })
          .where((s) => s != null)
          .cast<PokemonStat>()
          .toList();
    }
    return [];
  }

  /// Get the primary type (first type if multiple)
  String? get primaryType {
    return types.isNotEmpty ? types.first : null;
  }

  /// Get all type names as a formatted string
  String get typesString {
    return types.join(', ');
  }

  /// Get the Pokedex number
  int? get primaryPokedexNumber {
    return pokedexNumber;
  }

  /// Get HP stat for battle functionality
  int get hp {
    final hpStat = stats.firstWhere(
      (stat) => stat.name == 'hp',
      orElse: () => const PokemonStat(name: 'hp', baseStat: 1, effort: 0),
    );
    return hpStat.baseStat;
  }

  /// Get HP value (alias for hp getter for compatibility)
  int get hpValue => hp;

  /// Check if the pokemon matches a search query
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();

    // Check if it's a number (Pokédex number search)
    final number = int.tryParse(query);
    if (number != null) {
      return pokedexNumber == number;
    }

    // Text search in name and types
    return name.toLowerCase().contains(lowerQuery) ||
        types.any((type) => type.toLowerCase().contains(lowerQuery)) ||
        abilities.any((ability) => ability.toLowerCase().contains(lowerQuery));
  }

  @override
  String toString() {
    return 'PokemonCard{id: $id, name: $name, types: $typesString, pokedexNumber: $pokedexNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PokemonCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Pokemon stat model
class PokemonStat {
  const PokemonStat({
    required this.name,
    required this.baseStat,
    required this.effort,
  });

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']?['name'] ?? '',
      baseStat: json['base_stat'] ?? 0,
      effort: json['effort'] ?? 0,
    );
  }

  final String name;
  final int baseStat;
  final int effort;

  Map<String, dynamic> toJson() {
    return {
      'stat': {'name': name},
      'base_stat': baseStat,
      'effort': effort,
    };
  }

  @override
  String toString() {
    return '$name: $baseStat (EV: $effort)';
  }
}
