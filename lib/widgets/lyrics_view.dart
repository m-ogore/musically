import 'package:flutter/material.dart';

/// Widget for displaying hymn lyrics in a scrollable view
class LyricsView extends StatelessWidget {
  final String lyrics;

  const LyricsView({
    super.key,
    required this.lyrics,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SelectionArea(
        child: Text(
          lyrics,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            height: 1.8,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
