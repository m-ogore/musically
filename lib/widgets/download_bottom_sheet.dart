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
  bool _isBulkDownloading = false;
  int _bulkCompleted = 0;
  int _bulkTotal = 0;

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
    if (_isBulkDownloading) return;

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
          if (total != -1 && mounted) {
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

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '${trackName[0].toUpperCase()}${trackName.substring(1)} downloaded.'
                  : 'Failed to download ${trackName[0].toUpperCase()}${trackName.substring(1)}.',
            ),
          ),
        );
      }

      // Reload the player so the newly downloaded track becomes available
      if (success && mounted) {
        await context.read<PlayerProvider>().loadHymn(widget.hymn);
      }
    }
  }

  Future<void> _delete(String trackName) async {
    if (_isBulkDownloading) return;

    final wasDownloaded = _isDownloaded[trackName] ?? false;
    setState(() => _isDownloaded[trackName] = false);
    final success = await _downloadService.deleteTrack(
      widget.hymn.id,
      trackName,
    );

    if (!success && mounted) {
      setState(() => _isDownloaded[trackName] = wasDownloaded);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${trackName[0].toUpperCase()}${trackName.substring(1)} deleted.'
                : 'Failed to delete ${trackName[0].toUpperCase()}${trackName.substring(1)}.',
          ),
        ),
      );
    }

    // Reload player so the deleted track is removed from playback
    if (success && mounted) {
      await context.read<PlayerProvider>().loadHymn(widget.hymn);
    }
  }

  Future<void> _downloadAllAvailable(List<String> tracksToDisplay) async {
    if (_isBulkDownloading) return;

    final pendingTracks = tracksToDisplay.where((track) {
      final url = widget.hymn.audioPaths[track];
      return url != null && url.isNotEmpty && !(_isDownloaded[track] ?? false);
    }).toList();

    if (pendingTracks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All available tracks are already downloaded.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isBulkDownloading = true;
      _bulkCompleted = 0;
      _bulkTotal = pendingTracks.length;
      for (final track in pendingTracks) {
        _downloading[track] = true;
        _progress[track] = 0.0;
      }
    });

    int successCount = 0;
    int failedCount = 0;

    for (final track in pendingTracks) {
      final url = widget.hymn.audioPaths[track]!;
      final success = await _downloadService.downloadTrack(
        url,
        widget.hymn.id,
        track,
        onReceiveProgress: (count, total) {
          if (total != -1 && mounted) {
            setState(() {
              _progress[track] = count / total;
            });
          }
        },
      );

      if (!mounted) return;

      setState(() {
        _downloading[track] = false;
        _isDownloaded[track] = success;
        _bulkCompleted += 1;
      });

      if (success) {
        successCount += 1;
      } else {
        failedCount += 1;
      }
    }

    if (!mounted) return;

    setState(() {
      _isBulkDownloading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Download complete: $successCount succeeded, $failedCount failed.',
        ),
      ),
    );

    if (successCount > 0) {
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Offline Downloads',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _isBulkDownloading
                      ? null
                      : () => _downloadAllAvailable(tracksToDisplay),
                  icon: const Icon(Icons.download_for_offline, size: 18),
                  label: Text(
                    _isBulkDownloading ? 'Downloading...' : 'Download All',
                  ),
                ),
              ],
            ),
          ),
          if (_isBulkDownloading)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: _bulkTotal == 0 ? null : _bulkCompleted / _bulkTotal,
                  ),
                  const SizedBox(height: 6),
                  Text('$_bulkCompleted of $_bulkTotal tracks completed'),
                ],
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
