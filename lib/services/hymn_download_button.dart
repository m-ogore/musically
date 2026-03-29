import 'package:flutter/material.dart';
import '../services/download_service.dart';
import '../models/hymn.dart';
import '../utils/constants.dart';

/// A button that lets the user download or delete a hymn's audio tracks.
///
/// Shows:
///  - A download icon + "Download" when nothing is downloaded.
///  - A circular progress indicator while downloading.
///  - A checkmark + "Downloaded" (with a delete option) when complete.
///  - A warning icon when some tracks failed.
class HymnDownloadButton extends StatefulWidget {
  final Hymn hymn;

  const HymnDownloadButton({super.key, required this.hymn});

  @override
  State<HymnDownloadButton> createState() => _HymnDownloadButtonState();
}

class _HymnDownloadButtonState extends State<HymnDownloadButton> {
  final _downloadService = DownloadService();
  late HymnDownloadState _state;

  @override
  void initState() {
    super.initState();
    _state = _downloadService.getHymnState(
      widget.hymn.id,
      AppConstants.allTracks,
    );
    _downloadService.addListener(_onServiceChanged);
    _refreshState();
  }

  @override
  void dispose() {
    _downloadService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (!mounted) return;
    setState(() {
      _state = _downloadService.getHymnState(
        widget.hymn.id,
        AppConstants.allTracks,
      );
    });
  }

  Future<void> _refreshState() async {
    final updated = await _downloadService.refreshHymnState(
      widget.hymn.id,
      AppConstants.allTracks,
    );
    if (mounted) setState(() => _state = updated);
  }

  Future<void> _startDownload() async {
    await _downloadService.downloadHymn(
      widget.hymn.id,
      widget.hymn.audioPaths,
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove download?'),
        content: Text(
          'This will delete the locally saved audio for hymn ${widget.hymn.hymnNumber}. '
          'You can re-download it at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _downloadService.deleteHymn(widget.hymn.id, AppConstants.allTracks);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state.anyDownloading) {
      return _DownloadingIndicator(state: _state);
    }

    if (_state.allDownloaded) {
      return _DownloadedButton(onDelete: _confirmDelete);
    }

    // Check if any failed (partial state).
    final anyFailed = _state.tracks.values.any((t) => t.hasFailed);
    if (anyFailed) {
      return _FailedButton(onRetry: _startDownload);
    }

    // Default: not downloaded yet.
    return _DownloadButton(onDownload: _startDownload);
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _DownloadButton extends StatelessWidget {
  final VoidCallback onDownload;

  const _DownloadButton({required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onDownload,
      icon: const Icon(Icons.download_rounded),
      label: const Text('Download'),
    );
  }
}

class _DownloadingIndicator extends StatelessWidget {
  final HymnDownloadState state;

  const _DownloadingIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    final percent = (state.overallProgress * 100).toStringAsFixed(0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: state.overallProgress > 0 ? state.overallProgress : null,
            strokeWidth: 2,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Downloading… $percent%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DownloadedButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _DownloadedButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
        const SizedBox(width: 6),
        Text(
          'Downloaded',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.green),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          tooltip: 'Remove download',
          onPressed: onDelete,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class _FailedButton extends StatelessWidget {
  final VoidCallback onRetry;

  const _FailedButton({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      label: const Text('Retry download'),
    );
  }
}
