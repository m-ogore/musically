import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hymn_provider.dart';
import '../providers/player_provider.dart';
import '../providers/system_highlight_provider.dart';
import '../providers/visual_toggle_provider.dart';
import 'score_image_view.dart';

/// Widget for displaying the score image with system-level highlighting.
///
/// Ties the SystemHighlightProvider to the PlayerProvider's position stream.
class NotationView extends StatefulWidget {
  final Map<String, dynamic> data;

  const NotationView({super.key, required this.data});

  @override
  State<NotationView> createState() => _NotationViewState();
}

class _NotationViewState extends State<NotationView> {
  PlayerProvider? _playerProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupPlayerListener();
      
      // Load current hymn into highlighter
      final hymn = context.read<HymnProvider>().selectedHymn;
      if (hymn != null) {
        context.read<SystemHighlightProvider>().loadHymn(hymn);
        context.read<VisualToggleProvider>().loadHymnCoords(hymn.id);
      }
    });
  }

  @override
  void dispose() {
    _playerProvider?.removeListener(_onPlayerChanged);
    super.dispose();
  }

  void _setupPlayerListener() {
    _playerProvider = context.read<PlayerProvider>();
    _playerProvider!.addListener(_onPlayerChanged);
  }

  void _onPlayerChanged() {
    if (!mounted) return;
    
    final player = _playerProvider!;
    final highlighter = context.read<SystemHighlightProvider>();
    final visualToggle = context.read<VisualToggleProvider>();
    
    highlighter.updatePosition(player.currentPosition, player.isPlaying);
    visualToggle.syncWithAudio(player.currentPosition, player.isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final hymnProvider = context.watch<HymnProvider>();
    final highlighter = context.watch<SystemHighlightProvider>();
    final visualToggle = context.watch<VisualToggleProvider>();
    final currentHymn = hymnProvider.selectedHymn;

    // Load new hymn into highlighter if changed
    if (currentHymn != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
           context.read<SystemHighlightProvider>().loadHymn(currentHymn);
           context.read<VisualToggleProvider>().loadHymnCoords(currentHymn.id);
        }
      });
    }

    if (currentHymn == null ||
        currentHymn.scoreImagePath == null ||
        currentHymn.scoreImagePath!.isEmpty) {
      return const Center(child: Text('No notation available for this hymn.'));
    }

    return ScoreImageView(
      imagePath: currentHymn.scoreImagePath!,
      boundsData: visualToggle.boundsData,
      activeSystem: visualToggle.currentSystem,
      activeMeasure: visualToggle.currentMeasure,
      activeBeat: visualToggle.currentBeat,
      fallbackSystemIndex: highlighter.currentSystemIndex,
      fallbackTotalSystems: highlighter.totalSystems,
      isActive: visualToggle.isPlaying || highlighter.isActive,
    );
  }
}