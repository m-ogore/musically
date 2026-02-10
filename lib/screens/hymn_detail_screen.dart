import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hymn_provider.dart';
import '../widgets/lyrics_view.dart';
import '../widgets/notation_view.dart';
import '../widgets/new_score_view.dart';
import '../widgets/playback_header.dart';
import '../widgets/numeric_keypad.dart';
import '../providers/player_provider.dart';

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
  bool _showKeypad = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Load the hymn data and initialize audio
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hymnProvider = context.read<HymnProvider>();
      
      // Ensure hymns are loaded
      if (hymnProvider.hymns.isEmpty) {
        await hymnProvider.loadHymns();
      }
      
      await hymnProvider.selectHymn(widget.hymnId);
      
      if (mounted) {
        final player = context.read<PlayerProvider>();
        final hymn = hymnProvider.selectedHymn;
        
        // Find initial index
        if (hymn != null) {
          final index = hymnProvider.hymns.indexWhere((h) => h.id == hymn.id);
          if (index != -1) {
            _pageController = PageController(initialPage: index);
          }
          
          await player.initialize();
          await player.loadHymn(hymn);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Safely stop playback when leaving the screen
    try {
      Provider.of<PlayerProvider>(context, listen: false).stop();
    } catch (_) {
      // Background stop if provider is already gone
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HymnProvider>(
      builder: (context, hymnProvider, child) {
        return Scaffold(
          body: Builder(
            builder: (context) {
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

          if (hymnProvider.hymns.isEmpty) {
            return const Center(child: Text('No hymns available'));
          }

          return PageView.builder(
            controller: _pageController,
            itemCount: hymnProvider.hymns.length,
            onPageChanged: (index) async {
              final newHymn = hymnProvider.hymns[index];
              await hymnProvider.selectHymn(newHymn.id);
              if (mounted) {
                final player = context.read<PlayerProvider>();
                await player.loadHymn(newHymn);
              }
              },
            itemBuilder: (context, index) {
              final hymn = hymnProvider.hymns[index];
              
              // We only want to show content for the active hymn to avoid 
              // multiple audio/webview initializations in the background
              if (hymnProvider.selectedHymn?.id != hymn.id) {
                return const Center(child: CircularProgressIndicator());
              }

              return CustomScrollView(
                slivers: [
                  // App bar with persistent playback controls
                  SliverAppBar(
                    title: Hero(
                      tag: 'title-${hymn.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(hymn.title),
                      ),
                    ),
                    pinned: true,
                    actions: [
                      // View Mode Selector
                      PopupMenuButton<HymnViewMode>(
                        icon: Icon(
                          hymnProvider.viewMode == HymnViewMode.lyrics
                              ? Icons.text_fields
                              : hymnProvider.viewMode == HymnViewMode.imageScore
                                  ? Icons.image
                                  : Icons.music_note,
                        ),
                        onSelected: (mode) => hymnProvider.setViewMode(mode),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: HymnViewMode.lyrics,
                            child: Row(
                              children: [
                                Icon(Icons.text_fields),
                                SizedBox(width: 8),
                                Text('Lyrics View'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: HymnViewMode.imageScore,
                            child: Row(
                              children: [
                                Icon(Icons.image),
                                SizedBox(width: 8),
                                Text('Image Score'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: HymnViewMode.newScore,
                            child: Row(
                              children: [
                                Icon(Icons.music_note),
                                SizedBox(width: 8),
                                Text('New Score View'),
                              ],
                            ),
                          ),
                        ],
                        tooltip: 'Switch View Mode',
                      ),
                    ],
                    bottom: const PlaybackHeader(),
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
    
                        const Divider(height: 16),
                      ],
                    ),
                  ),
    
                  // Content: Switch based on View Mode
                  if (hymnProvider.viewMode == HymnViewMode.lyrics)
                    SliverToBoxAdapter(
                      child: LyricsView(
                        key: ValueKey('lyrics-${hymn.id}'),
                        lyrics: hymn.lyrics,
                      ),
                    )
                  else if (hymnProvider.viewMode == HymnViewMode.imageScore)
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: NotationView(
                        key: ValueKey('notation-${hymn.id}'),
                        data: const {}, 
                      ),
                    )
                  else
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: NewScoreView(
                        key: ValueKey('new-score-${hymn.id}'),
                        data: const {},
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: hymnProvider.showLyrics
          ? _buildBottomKeypad(hymnProvider)
          : null,
    );
      },
    );
  }

  Widget _buildBottomKeypad(HymnProvider hymnProvider) {
    if (_showKeypad) {
      return NumericKeypad(
        onHymnSelected: (number) async {
          // Attempt to find hymn
          final hymnExists = hymnProvider.hymns.any((h) => h.id == number);
          if (hymnExists) {
            await hymnProvider.selectHymn(number);
            if (mounted) {
              final player = context.read<PlayerProvider>();
              await player.loadHymn(hymnProvider.selectedHymn!);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Hymn #$number not found')),
              );
            }
          }
        },
        onClose: () => setState(() => _showKeypad = false),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 
        8, 
        16, 
        8 + MediaQuery.of(context).padding.bottom
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Search by number...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FloatingActionButton.small(
            onPressed: () => setState(() => _showKeypad = true),
            child: const Icon(Icons.dialpad),
          ),
        ],
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
