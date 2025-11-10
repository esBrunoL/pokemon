import 'package:flutter/material.dart';
import 'pokedex_top_menu.dart';

class PokedexFrameWrapper extends StatelessWidget {
  const PokedexFrameWrapper({
    super.key,
    required this.child,
    required this.screenTitle,
    this.showSearch = false,
  });

  final Widget child;
  final String screenTitle;
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final borderWidth = screenSize.width * 0.02; // 2% of screen width for border

    return Scaffold(
      backgroundColor: Colors.red, // Red background for border effect
      body: Container(
        margin: EdgeInsets.all(borderWidth), // 2% red border on all sides
        decoration: const BoxDecoration(
          color: Colors.black, // Black content area
          borderRadius: BorderRadius.all(Radius.circular(20)), // Round internal edges
        ),
        child: Column(
          children: [
            // Menu Bar with flexible height
            PokedexTopMenu(
              screenTitle: screenTitle,
              showSearch: showSearch,
            ),
            // Main Content
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
