/// Represents a hymn with all its associated data including
/// audio tracks, lyrics, and musical notation.
class Hymn {
  final String id;
  final String hymnNumber;
  final String title;
  final String author;
  final String history;
  final String lyrics;
  final String notationData; // Legacy field, kept for backward compatibility if needed
  final String? grandStaffData; // New field for Grand Staff (List of Systems)
  final List<Duration> noteTimestamps; // Note-level sync (bouncing ball)
  final List<Duration>? systemTimestamps; // System-level sync (page turns)
  final Map<String, String> audioPaths;
  final Duration audioOffset; // Delay before content starts (e.g. key intro)
  final double tempoFactor; // Ratio to scale audio time to notation time

  const Hymn({
    required this.id,
    required this.hymnNumber,
    required this.title,
    required this.author,
    required this.history,
    required this.lyrics,
    required this.notationData,
    this.grandStaffData,
    required this.noteTimestamps,
    this.systemTimestamps,
    required this.audioPaths,
    this.audioOffset = Duration.zero,
    this.tempoFactor = 1.0,
  });

  /// Creates a Hymn from a JSON map
  factory Hymn.fromJson(Map<String, dynamic> json) {
    return Hymn(
      id: json['id'] as String,
      hymnNumber: json['hymnNumber'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      history: json['history'] as String,
      lyrics: json['lyrics'] as String,
      notationData: json['notationData'] as String,
      grandStaffData: json['grandStaffData'] as String?,
      noteTimestamps: (json['noteTimestamps'] as List)
          .map((e) => Duration(milliseconds: e as int))
          .toList(),
      systemTimestamps: (json['systemTimestamps'] as List?)
          ?.map((e) => Duration(milliseconds: e as int))
          .toList(),
      audioPaths: Map<String, String>.from(json['audioPaths'] as Map),
      audioOffset: Duration(milliseconds: json['audioOffset'] as int? ?? 0),
      tempoFactor: (json['tempoFactor'] as num? ?? 1.0).toDouble(),
    );
  }

  /// Converts this Hymn to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hymnNumber': hymnNumber,
      'title': title,
      'author': author,
      'history': history,
      'lyrics': lyrics,
      'notationData': notationData,
      'grandStaffData': grandStaffData,
      'noteTimestamps': noteTimestamps.map((e) => e.inMilliseconds).toList(),
      'systemTimestamps': systemTimestamps?.map((e) => e.inMilliseconds).toList(),
      'audioPaths': audioPaths,
      'audioOffset': audioOffset.inMilliseconds,
      'tempoFactor': tempoFactor,
    };
  }

  /// Creates a copy of this Hymn with the given fields replaced
  Hymn copyWith({
    String? id,
    String? hymnNumber,
    String? title,
    String? author,
    String? history,
    String? lyrics,
    String? notationData,
    String? grandStaffData,
    List<Duration>? noteTimestamps,
    List<Duration>? systemTimestamps,
    Map<String, String>? audioPaths,
    Duration? audioOffset,
    double? tempoFactor,
  }) {
    return Hymn(
      id: id ?? this.id,
      hymnNumber: hymnNumber ?? this.hymnNumber,
      title: title ?? this.title,
      author: author ?? this.author,
      history: history ?? this.history,
      lyrics: lyrics ?? this.lyrics,
      notationData: notationData ?? this.notationData,
      grandStaffData: grandStaffData ?? this.grandStaffData,
      noteTimestamps: noteTimestamps ?? this.noteTimestamps,
      systemTimestamps: systemTimestamps ?? this.systemTimestamps,
      audioPaths: audioPaths ?? this.audioPaths,
      audioOffset: audioOffset ?? this.audioOffset,
      tempoFactor: tempoFactor ?? this.tempoFactor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Hymn &&
        other.id == id &&
        other.hymnNumber == hymnNumber &&
        other.title == title &&
        other.author == author &&
        other.history == history &&
        other.lyrics == lyrics &&
        other.notationData == notationData &&
        other.grandStaffData == grandStaffData &&
        _listEquals(other.noteTimestamps, noteTimestamps) &&
        _listEquals(other.systemTimestamps ?? [], systemTimestamps ?? []);
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      hymnNumber,
      title,
      author,
      history,
      lyrics,
      notationData,
      grandStaffData,
      Object.hashAll(noteTimestamps),
      Object.hashAll(systemTimestamps ?? []),
    );
  }

  @override
  String toString() {
    return 'Hymn(id: $id, title: $title, author: $author)';
  }
}
