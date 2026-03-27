import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/hymn.dart';

/// Repository for managing hymn data for the SDA Hymnal (SDAH).
class HymnRepository {
  List<Hymn>? _cachedHymns;
  static const String _defaultSupabaseUrl =
      'https://qxxdjnjljblzfdesdxyl.supabase.co';
  Set<String>? _assetKeys;
  bool _assetManifestAvailable = false;
  Map<String, String>? _scoreImageByHymnId;

  static final RegExp _scoreImagePattern = RegExp(
    r'^assets/images/SDAH_([^_]+)_page(\d+)\.png$',
  );

  /// Gets all available hymns (loaded from JSON).
  Future<List<Hymn>> getAllHymns() async {
    if (_cachedHymns != null) {
      return _cachedHymns!;
    }

    try {
      await _ensureAssetKeysLoaded();
      final String jsonString = await rootBundle.loadString(
        'assets/data/hymns.json',
      );
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

    // Construct dynamic paths using Supabase Storage public URLs
    // Base URL structure: https://[project_id].supabase.co/storage/v1/object/public/[bucket]/[path]
    final String supabaseUrl = _resolveSupabaseUrl();
    final String supabaseBaseUrl =
        '$supabaseUrl/storage/v1/object/public/audio';

    final Map<String, String> audioPaths = hasAudio
        ? {
            'soprano': '$supabaseBaseUrl/$id/soprano.mp3',
            'alto': '$supabaseBaseUrl/$id/alto.mp3',
            'tenor': '$supabaseBaseUrl/$id/tenor.mp3',
            'bass': '$supabaseBaseUrl/$id/bass.mp3',
            'instrumental': '$supabaseBaseUrl/$id/instrumental.mp3',
          }
        : {};

    final String musicXmlPath = hasMusicXml ? 'assets/notation/$id.xml' : '';

    final String scoreImagePath = _resolveScoreImagePath(id);

    return Hymn(
      id: id,
      hymnNumber: json['hymnNumber'] ?? id,
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      lyrics: json['lyrics'] ?? '',
      history: json['history'] ?? '',
      notationData: '', // Legacy field, empty
      grandStaffData:
          '', // Populated by VexFlowConverter separately if needed, or VexFlowRenderer just uses XML
      // Parse Timestamps
      noteTimestamps: [Duration.zero], // Minimal default
      systemTimestamps:
          (json['systemTimestamps'] as List<dynamic>?)
              ?.map((ms) => Duration(milliseconds: ms as int))
              .toList() ??
          [],

      audioOffset: json['audioOffset'] != null
          ? Duration(milliseconds: json['audioOffset'] as int)
          : Duration.zero,

      tempoFactor: (json['tempoFactor'] as num?)?.toDouble() ?? 1.0,

      audioPaths: audioPaths,
      musicXmlPath: musicXmlPath,
      scoreImagePath: scoreImagePath,
    );
  }

  String _resolveSupabaseUrl() {
    try {
      final String? fromEnv = dotenv.env['SUPABASE_URL'];
      if (fromEnv != null && fromEnv.isNotEmpty) {
        return fromEnv;
      }
    } catch (_) {
      // dotenv may be unavailable in builds where .env is not bundled.
    }

    return _defaultSupabaseUrl;
  }

  Future<void> _ensureAssetKeysLoaded() async {
    if (_assetKeys != null) {
      return;
    }

    try {
      final String manifestJson = await rootBundle.loadString(
        'AssetManifest.json',
      );
      final Map<String, dynamic> manifest =
          json.decode(manifestJson) as Map<String, dynamic>;
      _assetKeys = manifest.keys.toSet();
      _assetManifestAvailable = true;
      _buildScoreImageIndex();
    } catch (e) {
      _assetKeys = <String>{};
      _assetManifestAvailable = false;
      _scoreImageByHymnId = <String, String>{};
    }
  }

  void _buildScoreImageIndex() {
    final Map<String, String> byHymnId = <String, String>{};
    final Map<String, int> lowestPageByHymnId = <String, int>{};

    for (final String key in _assetKeys!) {
      final Match? match = _scoreImagePattern.firstMatch(key);
      if (match == null) continue;

      // Format: SDAH_<hymnNumber>_page<page>.png
      final String hymnId = _normalizeHymnId(match.group(1)!);
      final int page = int.tryParse(match.group(2) ?? '') ?? 9999;

      final int? existingPage = lowestPageByHymnId[hymnId];
      if (existingPage == null || page < existingPage) {
        lowestPageByHymnId[hymnId] = page;
        byHymnId[hymnId] = key;
      }
    }

    _scoreImageByHymnId = byHymnId;
  }

  String _resolveScoreImagePath(String hymnId) {
    if (_assetManifestAvailable) {
      final String normalizedId = _normalizeHymnId(hymnId);
      return _scoreImageByHymnId?[normalizedId] ?? '';
    }

    // Fallback for runtimes where AssetManifest isn't available.
    return 'assets/images/SDAH_${hymnId.padLeft(3, '0')}_page3.png';
  }

  String _normalizeHymnId(String value) {
    final String trimmed = value.trim();
    final String noLeadingZeros = trimmed.replaceFirst(RegExp(r'^0+'), '');
    return noLeadingZeros.isEmpty ? '0' : noLeadingZeros;
  }
}
