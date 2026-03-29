import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/hymn.dart';
import '../services/download_service.dart';

class AudioAvailabilityBadge extends StatefulWidget {
  final Hymn hymn;

  const AudioAvailabilityBadge({super.key, required this.hymn});

  @override
  State<AudioAvailabilityBadge> createState() => _AudioAvailabilityBadgeState();
}

class _AudioAvailabilityBadgeState extends State<AudioAvailabilityBadge> {
  final DownloadService _downloadService = DownloadService();
  late HymnDownloadState _state;
  late List<String> _trackNames;

  @override
  void initState() {
    super.initState();
    _trackNames = widget.hymn.audioPaths.keys
        .where((k) => (widget.hymn.audioPaths[k] ?? '').isNotEmpty)
        .toList();
    _state = _downloadService.getHymnState(widget.hymn.id, _trackNames);

    _downloadService.addListener(_onServiceChanged);
    _refreshState();
  }

  @override
  void didUpdateWidget(covariant AudioAvailabilityBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hymn.id != widget.hymn.id ||
        oldWidget.hymn.audioPaths != widget.hymn.audioPaths) {
      _trackNames = widget.hymn.audioPaths.keys
          .where((k) => (widget.hymn.audioPaths[k] ?? '').isNotEmpty)
          .toList();
      _state = _downloadService.getHymnState(widget.hymn.id, _trackNames);
      _refreshState();
    }
  }

  @override
  void dispose() {
    _downloadService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (!mounted) return;
    setState(() {
      _state = _downloadService.getHymnState(widget.hymn.id, _trackNames);
    });
  }

  Future<void> _refreshState() async {
    if (kIsWeb || _trackNames.isEmpty) return;
    final updated = await _downloadService.refreshHymnState(
      widget.hymn.id,
      _trackNames,
    );
    if (!mounted) return;
    setState(() => _state = updated);
  }

  @override
  Widget build(BuildContext context) {
    final hasOnlineAudio = _trackNames.isNotEmpty;

    if (!hasOnlineAudio) {
      return _badge(
        context,
        icon: Icons.cloud_off,
        text: 'No audio online',
        color: Theme.of(context).colorScheme.outline,
      );
    }

    if (_state.anyDownloading) {
      final percent = (_state.overallProgress * 100).clamp(0, 100).toInt();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                value: _state.overallProgress > 0
                    ? _state.overallProgress
                    : null,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Downloading $percent%',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      );
    }

    if (kIsWeb) {
      return _badge(
        context,
        icon: Icons.cloud_done,
        text: 'Audio online',
        color: Colors.green,
      );
    }

    final allDownloaded = _state.tracks.isNotEmpty && _state.allDownloaded;
    return _badge(
      context,
      icon: allDownloaded ? Icons.download_done : Icons.cloud,
      text: allDownloaded ? 'Downloaded' : 'Audio online',
      color: allDownloaded
          ? Colors.green
          : Theme.of(context).colorScheme.primary,
    );
  }

  Widget _badge(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
