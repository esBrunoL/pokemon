import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/card_list_screen.dart';
import 'services/api_service.dart';
import 'state/card_list_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
  }

  runApp(const PokemonTcgApp());
}

class PokemonTcgApp extends StatelessWidget {
  const PokemonTcgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PokemonTcgApiService>(
          create: (_) => PokemonTcgApiService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider<CardListProvider>(
          create: (context) => CardListProvider(
            context.read<PokemonTcgApiService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Pokémon TCG Browser',
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
        home: const RedFrameWrapper(
          child: CardListScreen(),
        ),
      ),
    );
  }
}

/// Wrapper widget that adds the red frame around the entire app
class RedFrameWrapper extends StatelessWidget {
  const RedFrameWrapper({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: Colors.red,
              width: 4,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
