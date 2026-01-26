import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import 'system_widget.dart';


import '../providers/hymn_provider.dart';

class NotationView extends StatelessWidget {
  final String grandStaffData;
  final List<Duration>? systemTimestamps;

  const NotationView({
    super.key,
    required this.grandStaffData,
    this.systemTimestamps,
  });

  List<Map<String, dynamic>> _parseSystems(String data) {
    if (data.isEmpty) return [];
    try {
      final decoded = jsonDecode(data);
      final systemsRaw = List<Map<String, dynamic>>.from(decoded['systems']);
      
      final globalKey = decoded['keySignature'];
      final globalTime = decoded['timeSignature'];

      return systemsRaw.map((s) {
        final Map<String, dynamic> newSystem = Map<String, dynamic>.from(s);
        if (globalKey != null && !newSystem.containsKey('keySignature')) {
          newSystem['keySignature'] = globalKey;
        }
        if (globalTime != null && !newSystem.containsKey('timeSignature')) {
          newSystem['timeSignature'] = globalTime;
        }
        return newSystem;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final hymnProvider = context.watch<HymnProvider>();
    final systems = _parseSystems(grandStaffData);

    if (systems.isEmpty) {
      return const Center(child: Text('No notation data available.'));
    }

    return Column(
      children: [
        Expanded(
          child: hymnProvider.notationMode == NotationViewMode.lineByLine
              ? _LineByLineView(
                  systems: systems,
                  systemTimestamps: systemTimestamps,
                  scrollMode: hymnProvider.scrollMode,
                )
              : _FullSheetView(systems: systems),
        ),
      ],
    );
  }
}

class _LineByLineView extends StatefulWidget {
  final List<Map<String, dynamic>> systems;
  final List<Duration>? systemTimestamps;
  final ScrollMode scrollMode;

  const _LineByLineView({
    required this.systems,
    this.systemTimestamps,
    required this.scrollMode,
  });

  @override
  State<_LineByLineView> createState() => _LineByLineViewState();
}

class _LineByLineViewState extends State<_LineByLineView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleAudioSync(Duration position) {
    if (widget.scrollMode != ScrollMode.audioSync ||
        widget.systemTimestamps == null ||
        widget.systemTimestamps!.isEmpty) {
      return;
    }

    for (int i = 0; i < widget.systemTimestamps!.length; i++) {
      if (position < widget.systemTimestamps![i]) {
        _animateToPage(i);
        break;
      }
    }
  }

  void _animateToPage(int index) {
    if (index == _currentPage || !_pageController.hasClients) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    setState(() => _currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    _handleAudioSync(player.adjustedPosition);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            'Line ${_currentPage + 1} of ${widget.systems.length}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.systems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: SystemWidget(
                  systemData: widget.systems[index],
                  isFirstSystem: true, // Always show time/key sig in Line-by-Line mode
                  highlight: index == _currentPage,
                  currentPosition: player.adjustedPosition,
                  showBorder: true,
                  showBackground: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FullSheetView extends StatelessWidget {
  final List<Map<String, dynamic>> systems;

  const _FullSheetView({required this.systems});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    
    return InteractiveViewer(
      minScale: 0.2,
      maxScale: 4.0,
      clipBehavior: Clip.none,
      boundaryMargin: const EdgeInsets.symmetric(vertical: 200, horizontal: 50),
      constrained: false,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: systems.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: SystemWidget(
                systemData: data,
                isFirstSystem: index == 0,
                currentPosition: player.adjustedPosition,
                showBorder: false,
                showBackground: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
