/// Represents a hymn with all its associated data including
/// audio tracks, lyrics, and musical notation.
class Hymn {
  final String id;
  final String title;
  final String author;
  final String history;
  final String lyrics;
  final String notationUrl;
  final Map<String, String> audioPaths;

  const Hymn({
    required this.id,
    required this.title,
    required this.author,
    required this.history,
    required this.lyrics,
    required this.notationUrl,
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
      notationUrl: json['notationUrl'] as String,
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
      'notationUrl': notationUrl,
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
    String? notationUrl,
    Map<String, String>? audioPaths,
  }) {
    return Hymn(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      history: history ?? this.history,
      lyrics: lyrics ?? this.lyrics,
      notationUrl: notationUrl ?? this.notationUrl,
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
        other.notationUrl == notationUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      author,
      history,
      lyrics,
      notationUrl,
    );
  }

  @override
  String toString() {
    return 'Hymn(id: $id, title: $title, author: $author)';
  }
}
