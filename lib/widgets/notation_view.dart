import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import 'vexflow_renderer.dart';
import '../services/vexflow_converter.dart';
import '../providers/hymn_provider.dart';

class NotationView extends StatelessWidget {
  final String grandStaffData;
  final List<Duration>? systemTimestamps;
  final String? musicXmlPath;

  const NotationView({
    super.key,
    required this.grandStaffData,
    this.systemTimestamps,
    this.musicXmlPath,
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
    // If we have a MusicXML path, load and parse it
    if (musicXmlPath != null && musicXmlPath!.isNotEmpty) {
      return _MusicXmlView(musicXmlPath: musicXmlPath!);
    }
    
    // Otherwise, use HymanProvider data
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
                  data: jsonDecode(grandStaffData),
                  systemTimestamps: systemTimestamps,
                  scrollMode: hymnProvider.scrollMode,
                )
              : _FullSheetView(data: jsonDecode(grandStaffData)),
        ),
      ],
    );
  }
}

class _LineByLineView extends StatefulWidget {
  final Map<String, dynamic> data;
  final List<Duration>? systemTimestamps;
  final ScrollMode scrollMode;

  const _LineByLineView({
    required this.data,
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
            'Line ${_currentPage + 1} of ${(widget.data['systems'] as List).length}',
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
            itemCount: (widget.data['systems'] as List).length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: VexFlowRenderer(
                  data: widget.data,
                  singleSystem: true,
                  systemIndex: index,
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
  final Map<String, dynamic> data;

  const _FullSheetView({required this.data});

  @override
  Widget build(BuildContext context) {
    return VexFlowRenderer(data: data);
  }
}

class _MusicXmlView extends StatefulWidget {
  final String musicXmlPath;
  
  const _MusicXmlView({required this.musicXmlPath});
  
  @override
  State<_MusicXmlView> createState() => _MusicXmlViewState();
}

class _MusicXmlViewState extends State<_MusicXmlView> {
  Map<String, dynamic>? _renderData;
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final xmlContent = await DefaultAssetBundle.of(context).loadString(widget.musicXmlPath);
      final converter = VexFlowConverter();
      final data = converter.fromMusicXML(xmlContent);
      if (mounted) {
        setState(() {
          _renderData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load XML: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    
    if (_renderData == null) {
      return const Center(child: Text('No data found'));
    }
    
    return VexFlowRenderer(data: _renderData!);
  }
}