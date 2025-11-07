import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_tcg_browser/models/pokemon_card.dart';

void main() {
  group('PokemonCard', () {
    test('should create PokemonCard from valid JSON', () {
      // Arrange
      final json = {
        'id': 'base1-4',
        'name': 'Charizard',
        'images': {
          'large': 'https://images.pokemontcg.io/base1/4_hires.png',
          'small': 'https://images.pokemontcg.io/base1/4.png',
        },
        'set': {'name': 'Base'},
        'rarity': 'Rare Holo',
        'evolvesFrom': 'Charmeleon',
        'nationalPokedexNumbers': [6],
        'supertype': 'Pokémon',
        'subtypes': ['Stage 2'],
      };

      // Act
      final card = PokemonCard.fromJson(json);

      // Assert
      expect(card.id, equals('base1-4'));
      expect(card.name, equals('Charizard'));
      expect(card.imageUrl,
          equals('https://images.pokemontcg.io/base1/4_hires.png'));
      expect(card.setName, equals('Base'));
      expect(card.rarity, equals('Rare Holo'));
      expect(card.evolvesFrom, equals('Charmeleon'));
      expect(card.nationalPokedexNumbers, equals([6]));
      expect(card.supertype, equals('Pokémon'));
      expect(card.subtypes, equals('Stage 2'));
    });

    test('should handle missing fields gracefully', () {
      // Arrange
      final json = {'id': 'test-1', 'name': 'Test Pokemon'};

      // Act
      final card = PokemonCard.fromJson(json);

      // Assert
      expect(card.id, equals('test-1'));
      expect(card.name, equals('Test Pokemon'));
      expect(card.imageUrl, equals(''));
      expect(card.setName, isNull);
      expect(card.rarity, isNull);
      expect(card.evolvesFrom, isNull);
      expect(card.evolvesTo, isEmpty);
      expect(card.nationalPokedexNumbers, isEmpty);
      expect(card.supertype, isNull);
      expect(card.subtypes, isNull);
    });

    test('should match search query by name', () {
      // Arrange
      const card = PokemonCard(
        id: 'test-1',
        name: 'Charizard',
        imageUrl: 'test.png',
        nationalPokedexNumbers: [6],
      );

      // Act & Assert
      expect(card.matchesSearch('charizard'), isTrue);
      expect(card.matchesSearch('Char'), isTrue);
      expect(card.matchesSearch('CHARIZARD'), isTrue);
      expect(card.matchesSearch('Pikachu'), isFalse);
      expect(card.matchesSearch(''), isTrue);
    });

    test('should match search query by Pokedex number', () {
      // Arrange
      const card = PokemonCard(
        id: 'test-1',
        name: 'Charizard',
        imageUrl: 'test.png',
        nationalPokedexNumbers: [6],
      );

      // Act & Assert
      expect(card.matchesSearch('6'), isTrue);
      expect(card.matchesSearch('25'), isFalse);
    });

    test('should return primary Pokedex number', () {
      // Arrange
      const card1 = PokemonCard(
        id: 'test-1',
        name: 'Test',
        imageUrl: 'test.png',
        nationalPokedexNumbers: [6, 150],
      );

      const card2 = PokemonCard(
        id: 'test-2',
        name: 'Test 2',
        imageUrl: 'test.png',
        nationalPokedexNumbers: [],
      );

      // Act & Assert
      expect(card1.primaryPokedexNumber, equals(6));
      expect(card2.primaryPokedexNumber, isNull);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      const card = PokemonCard(
        id: 'test-1',
        name: 'Charizard',
        imageUrl: 'test.png',
        setName: 'Base',
        rarity: 'Rare Holo',
        evolvesFrom: 'Charmeleon',
        evolvesTo: ['Mega Charizard X'],
        nationalPokedexNumbers: [6],
        supertype: 'Pokémon',
        subtypes: 'Stage 2',
      );

      // Act
      final json = card.toJson();

      // Assert
      expect(json['id'], equals('test-1'));
      expect(json['name'], equals('Charizard'));
      expect(json['images']['large'], equals('test.png'));
      expect(json['set']['name'], equals('Base'));
      expect(json['rarity'], equals('Rare Holo'));
      expect(json['evolvesFrom'], equals('Charmeleon'));
      expect(json['evolvesTo'], equals(['Mega Charizard X']));
      expect(json['nationalPokedexNumbers'], equals([6]));
      expect(json['supertype'], equals('Pokémon'));
      expect(json['subtypes'], equals('Stage 2'));
    });

    test('should be equal when IDs match', () {
      // Arrange
      const card1 =
          PokemonCard(id: 'test-1', name: 'Test 1', imageUrl: 'test.png');
      const card2 =
          PokemonCard(id: 'test-1', name: 'Test 2', imageUrl: 'test2.png');
      const card3 =
          PokemonCard(id: 'test-2', name: 'Test 1', imageUrl: 'test.png');

      // Act & Assert
      expect(card1, equals(card2)); // Same ID
      expect(card1, isNot(equals(card3))); // Different ID
      expect(card1.hashCode, equals(card2.hashCode));
      expect(card1.hashCode, isNot(equals(card3.hashCode)));
    });
  });
}
