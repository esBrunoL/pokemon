import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_tcg_browser/widgets/search_bar.dart';

void main() {
  group('PokemonSearchBar Widget Tests', () {
    testWidgets('should display hint text', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PokemonSearchBar(
              onSearchChanged: (query) {},
              hintText: 'Search Pokemon...',
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Search Pokemon...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should call onSearchChanged when text changes',
        (WidgetTester tester) async {
      // Arrange
      var searchQuery = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PokemonSearchBar(
              onSearchChanged: (query) {
                searchQuery = query;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Pikachu');
      await tester.pump(const Duration(milliseconds: 400)); // Wait for debounce

      // Assert
      expect(searchQuery, equals('Pikachu'));
    });

    testWidgets('should show clear button when text is entered',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PokemonSearchBar(onSearchChanged: (query) {})),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should clear text when clear button is pressed',
        (WidgetTester tester) async {
      // Arrange
      var searchQuery = 'initial';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PokemonSearchBar(
              onSearchChanged: (query) {
                searchQuery = query;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      // Act
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Assert
      expect(searchQuery, equals(''));
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('should have proper semantic labels',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PokemonSearchBar(onSearchChanged: (query) {})),
        ),
      );

      // Act & Assert
      expect(find.byTooltip('Clear search'), findsNothing); // Initially hidden

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      expect(find.byTooltip('Clear search'), findsOneWidget);
    });
  });
}
