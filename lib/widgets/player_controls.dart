import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';

/// Player controls widget with play/pause, seek, and progress bar
class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        _ProgressBar(
          position: playerProvider.currentPosition,
          duration: playerProvider.totalDuration,
          onSeek: (position) {
            playerProvider.seek(position);
          },
        ),
        
        const SizedBox(height: 16),
        
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Seek backward
            IconButton(
              icon: const Icon(Icons.replay_10),
              iconSize: 32,
              onPressed: playerProvider.currentHymn != null
                  ? () => playerProvider.seekBackward()
                  : null,
              tooltip: 'Rewind 10 seconds',
            ),
            
            const SizedBox(width: 24),
            
            // Play/Pause
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                iconSize: 48,
                onPressed: playerProvider.currentHymn != null
                    ? () => playerProvider.togglePlayPause()
                    : null,
                tooltip: playerProvider.isPlaying ? 'Pause' : 'Play',
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Seek forward
            IconButton(
              icon: const Icon(Icons.forward_10),
              iconSize: 32,
              onPressed: playerProvider.currentHymn != null
                  ? () => playerProvider.seekForward()
                  : null,
              tooltip: 'Forward 10 seconds',
            ),
          ],
        ),
      ],
    );
  }
}

/// Progress bar widget with time labels
class _ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const _ProgressBar({
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: duration.inMilliseconds > 0
                ? position.inMilliseconds.toDouble()
                : 0.0,
            min: 0.0,
            max: duration.inMilliseconds.toDouble(),
            onChanged: duration.inMilliseconds > 0
                ? (value) {
                    onSeek(Duration(milliseconds: value.toInt()));
                  }
                : null,
          ),
        ),
        
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatDuration(duration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
