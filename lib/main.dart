import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/pokemon_card.dart';
import 'screens/card_list_screen.dart';
import 'screens/battle_screen.dart';
import 'services/api_service.dart';
import 'state/card_list_provider.dart';
import 'state/team_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PokemonApiService>(
          create: (_) => PokemonApiService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider<CardListProvider>(
          create: (context) => CardListProvider(
            context.read<PokemonApiService>(),
          ),
        ),
        ChangeNotifierProvider<TeamProvider>(
          create: (_) => TeamProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Pokédx',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Dark theme with custom colors
          brightness: Brightness.dark,
          primarySwatch: Colors.red,
          primaryColor: Colors.red,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.red),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
            titleSmall: TextStyle(color: Colors.white),
          ),
          cardTheme: const CardThemeData(
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              side: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.grey),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.red),
        ),
        home: const CardListScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == '/battle') {
            final card = settings.arguments as PokemonCard?;
            if (card != null) {
              return MaterialPageRoute(
                builder: (context) => const BattleScreen(),
                settings: settings,
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
