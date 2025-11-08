/// Model for Pokemon type effectiveness data from PokeAPI
class TypeEffectiveness {
  const TypeEffectiveness({
    required this.typeName,
    required this.doubleDamageTo,
    required this.halfDamageTo,
    required this.noDamageTo,
    required this.doubleDamageFrom,
    required this.halfDamageFrom,
    required this.noDamageFrom,
  });

  factory TypeEffectiveness.fromJson(Map<String, dynamic> json) {
    final damageRelations = json['damage_relations'] as Map<String, dynamic>? ?? {};

    return TypeEffectiveness(
      typeName: json['name'] ?? '',
      doubleDamageTo: _parseTypeList(damageRelations['double_damage_to']),
      halfDamageTo: _parseTypeList(damageRelations['half_damage_to']),
      noDamageTo: _parseTypeList(damageRelations['no_damage_to']),
      doubleDamageFrom: _parseTypeList(damageRelations['double_damage_from']),
      halfDamageFrom: _parseTypeList(damageRelations['half_damage_from']),
      noDamageFrom: _parseTypeList(damageRelations['no_damage_from']),
    );
  }

  final String typeName;

  // Offensive relations (this type attacking others)
  final List<String> doubleDamageTo; // Super effective against these types
  final List<String> halfDamageTo; // Not very effective against these types
  final List<String> noDamageTo; // No effect on these types

  // Defensive relations (other types attacking this type)
  final List<String> doubleDamageFrom; // Weak to these types
  final List<String> halfDamageFrom; // Resistant to these types
  final List<String> noDamageFrom; // Immune to these types

  /// Parse a list of type objects into type names
  static List<String> _parseTypeList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e?['name']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'name': typeName,
      'damage_relations': {
        'double_damage_to': doubleDamageTo.map((t) => {'name': t}).toList(),
        'half_damage_to': halfDamageTo.map((t) => {'name': t}).toList(),
        'no_damage_to': noDamageTo.map((t) => {'name': t}).toList(),
        'double_damage_from': doubleDamageFrom.map((t) => {'name': t}).toList(),
        'half_damage_from': halfDamageFrom.map((t) => {'name': t}).toList(),
        'no_damage_from': noDamageFrom.map((t) => {'name': t}).toList(),
      }
    };
  }

  @override
  String toString() {
    return 'TypeEffectiveness{type: $typeName, weakTo: $doubleDamageFrom}';
  }
}

/// Helper class for calculating type effectiveness in battles
class TypeEffectivenessCalculator {
  TypeEffectivenessCalculator(this._typeData);

  final Map<String, TypeEffectiveness> _typeData;

  /// Calculate attack multiplier based on attacker and defender types
  /// Returns modified attack value with type effectiveness applied
  /// - Super effective: +50% (1.5x)
  /// - Not very effective: -30% (0.7x)
  /// - No effect: 0x
  int calculateEffectiveAttack(
      int baseAttack, List<String> attackerTypes, List<String> defenderTypes) {
    if (attackerTypes.isEmpty || defenderTypes.isEmpty) {
      return baseAttack;
    }

    double totalMultiplier = 1.0;

    // Check each attacker type against each defender type
    for (final attackType in attackerTypes) {
      final typeData = _typeData[attackType.toLowerCase()];
      if (typeData == null) continue;

      for (final defenseType in defenderTypes) {
        final defenseLower = defenseType.toLowerCase();

        // Check for super effective (double damage)
        if (typeData.doubleDamageTo.contains(defenseLower)) {
          totalMultiplier *= 1.5; // +50% attack
        }
        // Check for not very effective (half damage)
        else if (typeData.halfDamageTo.contains(defenseLower)) {
          totalMultiplier *= 0.7; // -30% attack
        }
        // Check for no effect
        else if (typeData.noDamageTo.contains(defenseLower)) {
          return 0; // No damage at all
        }
      }
    }

    return (baseAttack * totalMultiplier).round();
  }

  /// Get effectiveness message for UI feedback
  String getEffectivenessMessage(List<String> attackerTypes, List<String> defenderTypes) {
    if (attackerTypes.isEmpty || defenderTypes.isEmpty) {
      return '';
    }

    bool hasSuperEffective = false;
    bool hasNotVeryEffective = false;
    bool hasNoEffect = false;

    for (final attackType in attackerTypes) {
      final typeData = _typeData[attackType.toLowerCase()];
      if (typeData == null) continue;

      for (final defenseType in defenderTypes) {
        final defenseLower = defenseType.toLowerCase();

        if (typeData.noDamageTo.contains(defenseLower)) {
          hasNoEffect = true;
        } else if (typeData.doubleDamageTo.contains(defenseLower)) {
          hasSuperEffective = true;
        } else if (typeData.halfDamageTo.contains(defenseLower)) {
          hasNotVeryEffective = true;
        }
      }
    }

    if (hasNoEffect) {
      return "It doesn't affect the opponent!";
    } else if (hasSuperEffective && !hasNotVeryEffective) {
      return "It's super effective!";
    } else if (hasNotVeryEffective && !hasSuperEffective) {
      return "It's not very effective...";
    }

    return '';
  }
}
