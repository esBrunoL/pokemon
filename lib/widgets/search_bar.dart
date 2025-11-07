import 'dart:async';
import 'package:flutter/material.dart';

class PokemonSearchBar extends StatefulWidget {
  const PokemonSearchBar({
    super.key,
    required this.onSearchChanged,
    this.hintText = 'Search by name or Pokédex number...',
  });
  final Function(String) onSearchChanged;
  final String? hintText;

  @override
  State<PokemonSearchBar> createState() => _PokemonSearchBarState();
}

class _PokemonSearchBarState extends State<PokemonSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer with delay
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(query);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Row(
        children: [
          // Search icon
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: Colors.red, size: 20),
          ),

          // Search input field
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => widget.onSearchChanged(value),
            ),
          ),

          // Clear button
          if (_controller.text.isNotEmpty)
            IconButton(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
              tooltip: 'Clear search',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
