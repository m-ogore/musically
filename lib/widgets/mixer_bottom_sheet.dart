import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../utils/constants.dart';

/// Bottom sheet widget for controlling individual track volumes
class MixerBottomSheet extends StatelessWidget {
  const MixerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Voice Mixer',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Track controls
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: AppConstants.allTracks.map((trackName) {
                  return _TrackControl(trackName: trackName);
                }).toList(),
              ),
            ),
          ),
          
          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  /// Shows the mixer bottom sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MixerBottomSheet(),
    );
  }
}

/// Individual track control widget
class _TrackControl extends StatelessWidget {
  final String trackName;

  const _TrackControl({required this.trackName});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final mixerState = playerProvider.mixerState;
    
    final volume = mixerState.getVolume(trackName);
    final isMuted = mixerState.isMuted(trackName);
    final displayName = AppConstants.trackDisplayNames[trackName] ?? trackName;
    final trackColor = AppConstants.trackColors[trackName] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Track name and mute button
          Row(
            children: [
              // Color indicator
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              
              // Track name
              Expanded(
                child: Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isMuted ? Colors.grey : null,
                  ),
                ),
              ),
              
              // Volume percentage
              Text(
                '${(volume * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isMuted ? Colors.grey : trackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              
              // Mute button
              IconButton(
                icon: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: isMuted ? Colors.grey : trackColor,
                ),
                onPressed: () {
                  playerProvider.toggleMute(trackName);
                },
                tooltip: isMuted ? 'Unmute' : 'Mute',
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Volume slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: isMuted ? Colors.grey : trackColor,
              inactiveTrackColor: (isMuted ? Colors.grey : trackColor).withValues(alpha: 0.3),
              thumbColor: isMuted ? Colors.grey : trackColor,
              overlayColor: (isMuted ? Colors.grey : trackColor).withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: volume,
              min: 0.0,
              max: 1.0,
              onChanged: isMuted ? null : (value) {
                playerProvider.setTrackVolume(trackName, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
