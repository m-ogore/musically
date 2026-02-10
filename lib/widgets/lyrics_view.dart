import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hymn_provider.dart';
import 'score_image_view.dart';

/// Widget for displaying hymn lyrics with an optional score overlay
class LyricsView extends StatefulWidget {
  final String lyrics;

  const LyricsView({
    super.key,
    required this.lyrics,
  });

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  bool _showScoreOverlay = false;

  @override
  Widget build(BuildContext context) {
    final hymnProvider = context.watch<HymnProvider>();
    final currentHymn = hymnProvider.selectedHymn;

    return Stack(
      children: [
        // Lyrics Content
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 80), // Extra bottom padding for button
            child: SelectionArea(
              child: Text(
                widget.lyrics,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.8,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ),

        // Score Overlay (if enabled)
        if (_showScoreOverlay && currentHymn?.scoreImagePath != null)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  AppBar(
                    title: const Text('Music Score'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _showScoreOverlay = false),
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                  Expanded(
                    child: ScoreImageView(imagePath: currentHymn!.scoreImagePath!),
                  ),
                ],
              ),
            ),
          ),

        // Toggle Button
        if (!_showScoreOverlay && currentHymn?.scoreImagePath != null)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => setState(() => _showScoreOverlay = true),
              label: const Text('Show Score'),
              icon: const Icon(Icons.music_note),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
      ],
    );
  }
}
