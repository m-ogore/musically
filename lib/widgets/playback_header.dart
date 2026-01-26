import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../utils/constants.dart';

import '../providers/hymn_provider.dart';

class PlaybackHeader extends StatelessWidget implements PreferredSizeWidget {
  const PlaybackHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(130);

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final hymnProvider = context.watch<HymnProvider>();
    final theme = Theme.of(context);
    
    if (!player.isInitialized) {
      return Container(
        height: 160,
        color: theme.colorScheme.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main View & Playback Row
          Row(
            children: [
              IconButton(
                icon: Icon(
                  player.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 44,
                  color: theme.colorScheme.primary,
                ),
                onPressed: player.togglePlayPause,
              ),
              Expanded(
                child: Column(
                  children: [
                    Slider(
                      value: player.progress.clamp(0.0, 1.0),
                      onChanged: (value) {
                        final position = Duration(
                          milliseconds: (value * player.totalDuration.inMilliseconds).toInt(),
                        );
                        player.seek(position);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(player.currentPosition), style: theme.textTheme.bodySmall),
                          Text(_formatDuration(player.totalDuration), style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // View Toggle (Lyrics / Notation)
              IconButton(
                icon: Icon(hymnProvider.showLyrics ? Icons.music_note : Icons.text_fields),
                onPressed: hymnProvider.toggleView,
                tooltip: hymnProvider.showLyrics ? 'Show Notation' : 'Show Lyrics',
              ),
            ],
          ),
          
          const Divider(height: 16),
          
          // Voice & Notation Mode Selection Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Voice toggles
                _VoiceToggle(label: 'S', trackName: AppConstants.sopranoTrack, color: AppConstants.trackColors[AppConstants.sopranoTrack]!),
                const SizedBox(width: 8),
                _VoiceToggle(label: 'A', trackName: AppConstants.altoTrack, color: AppConstants.trackColors[AppConstants.altoTrack]!),
                const SizedBox(width: 8),
                _VoiceToggle(label: 'T', trackName: AppConstants.tenorTrack, color: AppConstants.trackColors[AppConstants.tenorTrack]!),
                const SizedBox(width: 8),
                _VoiceToggle(label: 'B', trackName: AppConstants.bassTrack, color: AppConstants.trackColors[AppConstants.bassTrack]!),
                const SizedBox(width: 8),
                _VoiceToggle(label: 'Piano', trackName: AppConstants.instrumentalTrack, color: AppConstants.trackColors[AppConstants.instrumentalTrack]!),
                
                if (hymnProvider.showNotation) ...[
                  const SizedBox(width: 16),
                  const VerticalDivider(width: 1),
                  const SizedBox(width: 16),
                  // Notation Mode
                  _ModeToggle<NotationViewMode>(
                    value: NotationViewMode.lineByLine,
                    groupValue: hymnProvider.notationMode,
                    icon: Icons.view_carousel,
                    onTap: () => hymnProvider.setNotationMode(NotationViewMode.lineByLine),
                  ),
                  const SizedBox(width: 8),
                  _ModeToggle<NotationViewMode>(
                    value: NotationViewMode.fullSheet,
                    groupValue: hymnProvider.notationMode,
                    icon: Icons.vertical_split,
                    onTap: () => hymnProvider.setNotationMode(NotationViewMode.fullSheet),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class _VoiceToggle extends StatelessWidget {
  final String label;
  final String trackName;
  final Color color;

  const _VoiceToggle({
    required this.label,
    required this.trackName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final isMuted = player.mixerState.isMuted(trackName);
    final isSelected = !isMuted;

    return InkWell(
      onTap: () => player.toggleMute(trackName),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ModeToggle<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeToggle({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

