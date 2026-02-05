import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hymn_provider.dart';
import 'osmd_view.dart';

class NotationView extends StatelessWidget {
  final Map<String, dynamic> data;

  const NotationView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hymnProvider = context.watch<HymnProvider>();
    final currentHymn = hymnProvider.selectedHymn;

    if (currentHymn == null || currentHymn.musicXmlPath == null || currentHymn.musicXmlPath!.isEmpty) {
      return const Center(child: Text('No notation available for this hymn.'));
    }

    return OsmdView(
      musicXmlPath: currentHymn.musicXmlPath!,
      mode: hymnProvider.notationMode,
    );
  }
}