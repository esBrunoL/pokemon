import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon_card.dart';

class TeamProvider extends ChangeNotifier {
  static const int maxTeamSize = 6;
  static const String _storageKey = 'pokemon_team';

  List<PokemonCard> _team = [];
  bool _isLoading = true;

  // Getters
  List<PokemonCard> get team => List.unmodifiable(_team);
  int get teamSize => _team.length;
  bool get isFull => _team.length >= maxTeamSize;
  bool get isEmpty => _team.isEmpty;
  bool get isLoading => _isLoading;
  int get availableSlots => maxTeamSize - _team.length;

  /// Initialize and load team from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _loadTeamFromStorage();

    _isLoading = false;
    notifyListeners();
  }

  /// Check if a Pokemon is in the team
  bool isPokemonInTeam(PokemonCard pokemon) {
    return _team.any((member) => member.id == pokemon.id);
  }

  /// Add a Pokemon to the team
  Future<bool> addToTeam(PokemonCard pokemon) async {
    if (isFull) {
      debugPrint('Team is full. Cannot add more Pokemon.');
      return false;
    }

    if (isPokemonInTeam(pokemon)) {
      debugPrint('Pokemon ${pokemon.name} is already in the team.');
      return false;
    }

    _team.add(pokemon);
    await _saveTeamToStorage();
    notifyListeners();

    debugPrint('Added ${pokemon.name} to team. Team size: ${_team.length}');
    return true;
  }

  /// Remove a Pokemon from the team
  Future<bool> removeFromTeam(PokemonCard pokemon) async {
    final initialLength = _team.length;
    _team.removeWhere((member) => member.id == pokemon.id);
    final removed = _team.length < initialLength;

    if (removed) {
      await _saveTeamToStorage();
      notifyListeners();
      debugPrint('Removed ${pokemon.name} from team. Team size: ${_team.length}');
    }

    return removed;
  }

  /// Clear the entire team
  Future<void> clearTeam() async {
    _team.clear();
    await _saveTeamToStorage();
    notifyListeners();
    debugPrint('Team cleared.');
  }

  /// Save team to local storage
  Future<void> _saveTeamToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teamJson = _team.map((pokemon) => pokemon.toJson()).toList();
      final jsonString = json.encode(teamJson);
      await prefs.setString(_storageKey, jsonString);
      debugPrint('Team saved to storage.');
    } catch (e) {
      debugPrint('Error saving team to storage: $e');
    }
  }

  /// Load team from local storage
  Future<void> _loadTeamFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> teamJson = json.decode(jsonString);
        _team = teamJson.map((json) => PokemonCard.fromJson(json as Map<String, dynamic>)).toList();
        debugPrint('Team loaded from storage. Team size: ${_team.length}');
      } else {
        _team = [];
        debugPrint('No team found in storage.');
      }
    } catch (e) {
      debugPrint('Error loading team from storage: $e');
      _team = [];
    }
  }

  /// Get team member by index
  PokemonCard? getTeamMember(int index) {
    if (index >= 0 && index < _team.length) {
      return _team[index];
    }
    return null;
  }
}
