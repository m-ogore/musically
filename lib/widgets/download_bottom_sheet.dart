import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hymn.dart';
import '../providers/player_provider.dart';
import '../utils/constants.dart';
import '../services/download_service.dart';

class DownloadBottomSheet extends StatefulWidget {
  final Hymn hymn;

  const DownloadBottomSheet({super.key, required this.hymn});

  @override
  State<DownloadBottomSheet> createState() => _DownloadBottomSheetState();
}

class _DownloadBottomSheetState extends State<DownloadBottomSheet> {
  final DownloadService _downloadService = DownloadService();
  final Map<String, bool> _downloading = {};
  final Map<String, double> _progress = {};
  final Map<String, bool> _isDownloaded = {};

  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    for (final track in AppConstants.allTracks) {
      if (widget.hymn.audioPaths.containsKey(track)) {
        final isDownloaded = await _downloadService.isTrackDownloaded(
          widget.hymn.id,
          track,
        );
        _isDownloaded[track] = isDownloaded;
      }
    }
    setState(() {
      _isLoadingStatus = false;
    });
  }

  Future<void> _toggleDownload(String trackName, String url) async {
    if (_isDownloaded[trackName] == true) {
      await _delete(trackName);
    } else {
      // Download
      setState(() {
        _downloading[trackName] = true;
        _progress[trackName] = 0.0;
      });

      final success = await _downloadService.downloadTrack(
        url,
        widget.hymn.id,
        trackName,
        onReceiveProgress: (count, total) {
          if (total != -1) {
            setState(() {
              _progress[trackName] = count / total;
            });
          }
        },
      );

      setState(() {
        _downloading[trackName] = false;
        _isDownloaded[trackName] = success;
      });
      // Reload the player so the newly downloaded track becomes available
      if (success && mounted) {
        await context.read<PlayerProvider>().loadHymn(widget.hymn);
      }
    }
  }

  Future<void> _delete(String trackName) async {
    setState(() => _isDownloaded[trackName] = false);
    await _downloadService.deleteTrack(widget.hymn.id, trackName);
    // Reload player so the deleted track is removed from playback
    if (mounted) {
      await context.read<PlayerProvider>().loadHymn(widget.hymn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingStatus) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final tracksToDisplay = AppConstants.allTracks
        .where((track) => widget.hymn.audioPaths.containsKey(track))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Offline Downloads',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ...tracksToDisplay.map((track) {
            final isDownloading = _downloading[track] ?? false;
            final isDownloaded = _isDownloaded[track] ?? false;
            final progress = _progress[track] ?? 0.0;
            final url = widget.hymn.audioPaths[track];

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(
                track[0].toUpperCase() + track.substring(1),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: SizedBox(
                width: 48,
                height: 48,
                child: isDownloading
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(value: progress),
                      )
                    : IconButton(
                        icon: Icon(
                          isDownloaded ? Icons.download_done : Icons.download,
                          color: isDownloaded
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: url != null
                            ? () => _toggleDownload(track, url)
                            : null,
                      ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
