/// Represents a hymn with all its associated data including
/// audio tracks, lyrics, and musical notation.
class Hymn {
  final String id;
  final String title;
  final String author;
  final String history;
  final String lyrics;
  final String notationData;
  final List<Duration> noteTimestamps;
  final Map<String, String> audioPaths;

  const Hymn({
    required this.id,
    required this.title,
    required this.author,
    required this.history,
    required this.lyrics,
    required this.notationData,
    required this.noteTimestamps,
    required this.audioPaths,
  });

  /// Creates a Hymn from a JSON map
  factory Hymn.fromJson(Map<String, dynamic> json) {
    return Hymn(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      history: json['history'] as String,
      lyrics: json['lyrics'] as String,
      notationData: json['notationData'] as String,
      noteTimestamps: (json['noteTimestamps'] as List)
          .map((e) => Duration(milliseconds: e as int))
          .toList(),
      audioPaths: Map<String, String>.from(json['audioPaths'] as Map),
    );
  }

  /// Converts this Hymn to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'history': history,
      'lyrics': lyrics,
      'notationData': notationData,
      'noteTimestamps': noteTimestamps.map((e) => e.inMilliseconds).toList(),
      'audioPaths': audioPaths,
    };
  }

  /// Creates a copy of this Hymn with the given fields replaced
  Hymn copyWith({
    String? id,
    String? title,
    String? author,
    String? history,
    String? lyrics,
    String? notationData,
    List<Duration>? noteTimestamps,
    Map<String, String>? audioPaths,
  }) {
    return Hymn(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      history: history ?? this.history,
      lyrics: lyrics ?? this.lyrics,
      notationData: notationData ?? this.notationData,
      noteTimestamps: noteTimestamps ?? this.noteTimestamps,
      audioPaths: audioPaths ?? this.audioPaths,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Hymn &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.history == history &&
        other.lyrics == lyrics &&
        other.notationData == notationData &&
        _listEquals(other.noteTimestamps, noteTimestamps);
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
      title,
      author,
      history,
      lyrics,
      notationData,
      Object.hashAll(noteTimestamps),
    );
  }

  @override
  String toString() {
    return 'Hymn(id: $id, title: $title, author: $author)';
  }
}
