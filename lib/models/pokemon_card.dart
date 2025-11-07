class PokemonCard {
  const PokemonCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.setName,
    this.rarity,
    this.evolvesFrom,
    this.evolvesTo = const [],
    this.nationalPokedexNumbers = const [],
    this.supertype,
    this.subtypes,
  });
  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    return PokemonCard(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['images']?['large'] ?? json['images']?['small'] ?? '',
      setName: json['set']?['name'],
      rarity: json['rarity'],
      evolvesFrom: json['evolvesFrom'],
      evolvesTo: _parseStringList(json['evolvesTo']),
      nationalPokedexNumbers: _parseIntList(json['nationalPokedexNumbers']),
      supertype: json['supertype'],
      subtypes: json['subtypes']?.join(', '),
    );
  }
  final String id;
  final String name;
  final String imageUrl;
  final String? setName;
  final String? rarity;
  final String? evolvesFrom;
  final List<String> evolvesTo;
  final List<int> nationalPokedexNumbers;
  final String? supertype;
  final String? subtypes;

  /// Convert PokemonCard to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': {
        'large': imageUrl,
      },
      'set': setName != null ? {'name': setName} : null,
      'rarity': rarity,
      'evolvesFrom': evolvesFrom,
      'evolvesTo': evolvesTo,
      'nationalPokedexNumbers': nationalPokedexNumbers,
      'supertype': supertype,
      'subtypes': subtypes,
    };
  }

  /// Helper method to safely parse string lists from JSON
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Helper method to safely parse integer lists from JSON
  static List<int> _parseIntList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => e is int ? e : int.tryParse(e?.toString() ?? ''))
          .where((n) => n != null)
          .cast<int>()
          .toList();
    }
    return [];
  }

  /// Get the primary national Pokédex number (first one if multiple)
  int? get primaryPokedexNumber {
    return nationalPokedexNumbers.isNotEmpty
        ? nationalPokedexNumbers.first
        : null;
  }

  /// Check if the card matches a search query
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();

    // Check if it's a number (Pokédex number search)
    final number = int.tryParse(query);
    if (number != null) {
      return nationalPokedexNumbers.contains(number);
    }

    // Text search in name, set name, and rarity
    return name.toLowerCase().contains(lowerQuery) ||
        (setName?.toLowerCase().contains(lowerQuery) ?? false) ||
        (rarity?.toLowerCase().contains(lowerQuery) ?? false);
  }

  @override
  String toString() {
    return 'PokemonCard{id: $id, name: $name, setName: $setName, rarity: $rarity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PokemonCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
