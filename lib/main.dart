import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/card_list_screen.dart';
import 'screens/battle_screen.dart';
import 'screens/my_team_screen.dart';
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
        title: 'Pokédex',
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
        home: const PokedexFrameWrapper(
          child: CardListScreen(),
        ),
      ),
    );
  }
}

/// Wrapper widget that adds the red frame with 5% margins and menu bar
class PokedexFrameWrapper extends StatelessWidget {
  const PokedexFrameWrapper({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final borderWidth = screenSize.width * 0.02; // 2% of screen width for border

    return Scaffold(
      backgroundColor: Colors.red, // Red background for border effect
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(borderWidth), // 2% red border on all sides
          decoration: const BoxDecoration(
            color: Colors.black, // Black content area
            borderRadius: BorderRadius.all(Radius.circular(20)), // Round internal edges
          ),
          child: Column(
            children: [
              // Menu Bar with flexible height
              const PokedexMenuBar(),
              // Main Content
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menu bar widget containing Pokédex title, search, and buttons
class PokedexMenuBar extends StatefulWidget {
  const PokedexMenuBar({super.key});

  @override
  State<PokedexMenuBar> createState() => _PokedexMenuBarState();
}

class _PokedexMenuBarState extends State<PokedexMenuBar> {
  bool _isSearchExpanded = false;

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });

    if (!_isSearchExpanded) {
      // Clear search when closing
      context.read<CardListProvider>().clearSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Fixed height menu bar
      decoration: const BoxDecoration(
        color: Colors.red, // Red background for menu bar
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // Pokédx Title
            const Text(
              'Pokédex',
              style: TextStyle(
                color: Colors.black, // Bold black text on red background
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 16),

            // Search bar - appears between title and buttons when expanded
            if (_isSearchExpanded)
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: Consumer<CardListProvider>(
                    builder: (context, provider, child) {
                      return TextField(
                        autofocus: true,
                        onChanged: provider.searchCards,
                        decoration: const InputDecoration(
                          hintText: 'Search Pokémon...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(color: Colors.grey),
                          isDense: true,
                        ),
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      );
                    },
                  ),
                ),
              ),

            if (_isSearchExpanded) const SizedBox(width: 16),

            if (!_isSearchExpanded) const Spacer(),

            // Search Button
            Semantics(
              label: _isSearchExpanded ? 'Close search' : 'Search Pokémon',
              child: IconButton(
                icon: Icon(
                  _isSearchExpanded ? Icons.close : Icons.search,
                  color: Colors.black, // Bold black icons on red background
                  size: 28, // Make icons more prominent/bold
                  weight: 700, // Bold weight
                ),
                onPressed: _toggleSearch,
              ),
            ),

            const SizedBox(width: 8),

            // Battle Simulator Button
            Semantics(
              label: 'Battle Simulator',
              child: IconButton(
                icon: const Icon(
                  Icons.flash_on,
                  color: Colors.black, // Bold black icons on red background
                  size: 28, // Make icons more prominent/bold
                  weight: 700, // Bold weight
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BattleScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 8),

            // My Team Button
            Consumer<TeamProvider>(
              builder: (context, teamProvider, child) {
                final teamSize = teamProvider.teamSize;
                return Stack(
                  children: [
                    Semantics(
                      label: 'My Team ($teamSize/6 Pokemon)',
                      child: IconButton(
                        icon: const Icon(
                          Icons.group,
                          color: Colors.black, // Bold black icons on red background
                          size: 28, // Make icons more prominent/bold
                          weight: 700, // Bold weight
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyTeamScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    if (teamSize > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$teamSize',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
