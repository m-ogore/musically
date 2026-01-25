/// Represents an individual audio track for a voice part or instrumental
class AudioTrack {
  final String name;
  final String path;
  final double volume;
  final bool isMuted;

  const AudioTrack({
    required this.name,
    required this.path,
    this.volume = 1.0,
    this.isMuted = false,
  });

  /// Creates a copy of this AudioTrack with the given fields replaced
  AudioTrack copyWith({
    String? name,
    String? path,
    double? volume,
    bool? isMuted,
  }) {
    return AudioTrack(
      name: name ?? this.name,
      path: path ?? this.path,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  /// Returns the effective volume (0.0 if muted, otherwise the set volume)
  double get effectiveVolume => isMuted ? 0.0 : volume;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AudioTrack &&
        other.name == name &&
        other.path == path &&
        other.volume == volume &&
        other.isMuted == isMuted;
  }

  @override
  int get hashCode {
    return Object.hash(name, path, volume, isMuted);
  }

  @override
  String toString() {
    return 'AudioTrack(name: $name, volume: $volume, muted: $isMuted)';
  }
}
