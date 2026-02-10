import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hymn_provider.dart';
import 'osmd_view.dart';

class LiveScoreView extends StatelessWidget {
  final Map<String, dynamic> data;

  const LiveScoreView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hymnProvider = context.watch<HymnProvider>();
    final currentHymn = hymnProvider.selectedHymn;

    if (currentHymn == null || 
        (currentHymn.musicXmlPath == null && currentHymn.notationData.isEmpty)) {
      return const Center(child: Text('No live score data available.'));
    }

    // Prefer file path for efficiency, fallback to legacy data string if needed (though OsmdView takes path)
    // For now, we assume musicXmlPath is populated for 'Live' rendering.
    final xmlPath = currentHymn.musicXmlPath ?? 'assets/notation/${currentHymn.id}.xml';

    return OsmdView(
      musicXmlPath: xmlPath,
      mode: hymnProvider.notationMode,
    );
  }
}
