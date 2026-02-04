import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/hymn.dart';

/// Repository for managing hymn data for the SDA Hymnal (SDAH).
class HymnRepository {
  List<Hymn>? _cachedHymns;

  /// Gets all available hymns (loaded from JSON).
  Future<List<Hymn>> getAllHymns() async {
    if (_cachedHymns != null) {
      return _cachedHymns!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/hymns.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      _cachedHymns = jsonList.map((json) => _fromJson(json)).toList();
      return _cachedHymns!;
    } catch (e) {
      debugPrint('Error loading hymns: $e');
      return [];
    }
  }

  /// Gets a hymn by its ID (Hymn Number).
  Future<Hymn?> getHymnById(String id) async {
    final hymns = await getAllHymns();
    try {
      return hymns.firstWhere((hymn) => hymn.id == id);
    } catch (e) {
      return null;
    }
  }

  Hymn _fromJson(Map<String, dynamic> json) {
    final String id = json['id'];
    final bool hasAudio = json['hasAudio'] ?? false;
    final bool hasMusicXml = json['hasMusicXml'] ?? false;
    
    // Construct dynamic paths
    final Map<String, String> audioPaths = hasAudio ? {
      'soprano': 'assets/audio/$id/soprano.mp3',
      'alto': 'assets/audio/$id/alto.mp3',
      'tenor': 'assets/audio/$id/tenor.mp3',
      'bass': 'assets/audio/$id/bass.mp3',
      'instrumental': 'assets/audio/$id/instrumental.mp3',
    } : {};

    final String musicXmlPath = hasMusicXml ? 'assets/notation/$id.xml' : '';

    return Hymn(
      id: id,
      hymnNumber: json['hymnNumber'] ?? id,
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      lyrics: json['lyrics'] ?? '',
      history: json['history'] ?? '',
      notationData: '', // Legacy field, empty
      grandStaffData: '', // Populated by VexFlowConverter separately if needed, or VexFlowRenderer just uses XML
      
      // Parse Timestamps
      noteTimestamps: [Duration.zero], // Minimal default
      systemTimestamps: (json['systemTimestamps'] as List<dynamic>?)
          ?.map((ms) => Duration(milliseconds: ms as int))
          .toList() ?? [],
      
      audioOffset: json['audioOffset'] != null 
          ? Duration(milliseconds: json['audioOffset'] as int) 
          : Duration.zero,
      
      tempoFactor: (json['tempoFactor'] as num?)?.toDouble() ?? 1.0,
      
      audioPaths: audioPaths,
      musicXmlPath: musicXmlPath,
    );
  }
}