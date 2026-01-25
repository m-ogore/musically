import 'package:flutter/material.dart';
import '../models/hymn.dart';
import '../widgets/hymn_tile.dart';

class HymnSearchDelegate extends SearchDelegate<String?> {
  final List<Hymn> hymns;
  final Function(String) onHymnSelected;

  HymnSearchDelegate({
    required this.hymns,
    required this.onHymnSelected,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildFilteredList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildFilteredList();
  }

  Widget _buildFilteredList() {
    // Regex Search Logic
    // If query is numeric, match ID
    // If query is text, match Title or Lyrics (optional) or Author
    // Flexible matching
    
    final RegExp regex;
    try {
      // Create a case-insensitive regex from the query
      // Escape special characters to prevent regex application errors from user input
      regex = RegExp(RegExp.escape(query), caseSensitive: false);
    } catch (e) {
      return const Center(child: Text('Invalid search pattern'));
    }

    final filteredHymns = hymns.where((hymn) {
      if (query.isEmpty) return true;
      
      // Check ID (Number)
      if (hymn.id.contains(query)) return true;
      
      // Check Title (Regex)
      if (regex.hasMatch(hymn.title)) return true;
      
      // Check Author (Regex)
      if (regex.hasMatch(hymn.author)) return true;
      
      return false;
    }).toList();

    return ListView.builder(
      itemCount: filteredHymns.length,
      itemBuilder: (context, index) {
        final hymn = filteredHymns[index];
        return HymnTile(
          hymn: hymn,
          onTap: () {
            close(context, hymn.id);
            onHymnSelected(hymn.id);
          },
        );
      },
    );
  }
}
