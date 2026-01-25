import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hymn_provider.dart';
import '../widgets/lyrics_view.dart';
import '../widgets/notation_view.dart';
import 'player_screen.dart';

/// Detail screen for viewing a specific hymn
class HymnDetailScreen extends StatefulWidget {
  final String hymnId;

  const HymnDetailScreen({
    super.key,
    required this.hymnId,
  });

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load the hymn when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HymnProvider>().selectHymn(widget.hymnId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HymnProvider>(
        builder: (context, hymnProvider, child) {
          if (hymnProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (hymnProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    hymnProvider.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final hymn = hymnProvider.selectedHymn;
          if (hymn == null) {
            return const Center(child: Text('Hymn not found'));
          }

          return CustomScrollView(
            slivers: [
              // App bar with toggle button
              SliverAppBar(
                title: Text(hymn.title),
                pinned: true,
                actions: [
                  // View toggle button
                  IconButton(
                    icon: Icon(
                      hymnProvider.showLyrics
                          ? Icons.music_note
                          : Icons.text_fields,
                    ),
                    onPressed: () => hymnProvider.toggleView(),
                    tooltip: hymnProvider.showLyrics
                        ? 'Show Notation'
                        : 'Show Lyrics',
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Text(
                        'By ${hymn.author}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                    // History (expandable)
                    if (hymn.history.isNotEmpty)
                      _HistorySection(history: hymn.history),

                    const Divider(height: 32),

                    // Lyrics or Notation view
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: hymnProvider.showLyrics
                          ? LyricsView(
                              key: const ValueKey('lyrics'),
                              lyrics: hymn.lyrics,
                            )
                          : NotationView(
                              key: const ValueKey('notation'),
                              notationData: hymn.notationData,
                              noteTimestamps: hymn.noteTimestamps,
                            ),
                    ),

                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<HymnProvider>(
        builder: (context, hymnProvider, child) {
          final hymn = hymnProvider.selectedHymn;
          if (hymn == null) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () => _openPlayer(context, hymn),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play'),
          );
        },
      ),
    );
  }

  void _openPlayer(BuildContext context, hymn) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(hymn: hymn),
      ),
    );
  }
}

/// Expandable history section
class _HistorySection extends StatefulWidget {
  final String history;

  const _HistorySection({required this.history});

  @override
  State<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<_HistorySection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text(
              widget.history,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ),
      ],
    );
  }
}
