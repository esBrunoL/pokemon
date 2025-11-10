import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/team_provider.dart';
import '../state/card_list_provider.dart';
import '../screens/battle_screen.dart';
import '../screens/gym_screen.dart';
import '../screens/my_team_screen.dart';

class PokedexTopMenu extends StatefulWidget {
  final String screenTitle;
  final bool showSearch;

  const PokedexTopMenu({
    super.key,
    required this.screenTitle,
    this.showSearch = false,
  });

  @override
  State<PokedexTopMenu> createState() => _PokedexTopMenuState();
}

class _PokedexTopMenuState extends State<PokedexTopMenu> {
  bool _isSearchExpanded = false;

  void _toggleSearch() {
    if (!widget.showSearch) return;

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
      height: _isSearchExpanded && widget.showSearch ? 100 : 60, // Dynamic height
      decoration: const BoxDecoration(
        color: Colors.red, // Red background for menu bar
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Main menu row
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  // Screen Title
                  Text(
                    widget.screenTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  // Search Button (only show if search is enabled)
                  if (widget.showSearch) ...[
                    Semantics(
                      label: _isSearchExpanded ? 'Close search' : 'Search Pokémon',
                      child: IconButton(
                        icon: Icon(
                          _isSearchExpanded ? Icons.close : Icons.search,
                          color: Colors.black,
                          size: 28,
                          weight: 700,
                        ),
                        onPressed: _toggleSearch,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Battle Simulator Button
                  Semantics(
                    label: 'Battle Simulator',
                    child: IconButton(
                      icon: const Icon(
                        Icons.flash_on,
                        color: Colors.black,
                        size: 28,
                        weight: 700,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BattleScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Gym Challenge Button
                  Semantics(
                    label: 'Gym Challenge',
                    child: IconButton(
                      icon: const Icon(
                        Icons.stadium,
                        color: Colors.black,
                        size: 28,
                        weight: 700,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GymScreen(),
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
                                color: Colors.black,
                                size: 28,
                                weight: 700,
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
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

            // Search bar - appears below main menu when expanded
            if (_isSearchExpanded && widget.showSearch)
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
          ],
        ),
      ),
    );
  }
}
