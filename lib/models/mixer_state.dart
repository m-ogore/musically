/// Manages the state of the audio mixer including volume levels
/// and mute states for all tracks
class MixerState {
  final Map<String, double> volumes;
  final Map<String, bool> mutedTracks;

  const MixerState({
    required this.volumes,
    required this.mutedTracks,
  });

  /// Creates a default MixerState with all tracks at full volume and unmuted
  factory MixerState.initial() {
    return MixerState(
      volumes: {
        'soprano': 1.0,
        'alto': 1.0,
        'tenor': 1.0,
        'bass': 1.0,
        'instrumental': 1.0,
      },
      mutedTracks: {
        'soprano': false,
        'alto': false,
        'tenor': false,
        'bass': false,
        'instrumental': false,
      },
    );
  }

  /// Creates a copy of this MixerState with the given fields replaced
  MixerState copyWith({
    Map<String, double>? volumes,
    Map<String, bool>? mutedTracks,
  }) {
    return MixerState(
      volumes: volumes ?? Map.from(this.volumes),
      mutedTracks: mutedTracks ?? Map.from(this.mutedTracks),
    );
  }

  /// Updates the volume for a specific track
  MixerState setVolume(String trackName, double volume) {
    final newVolumes = Map<String, double>.from(volumes);
    newVolumes[trackName] = volume.clamp(0.0, 1.0);
    return copyWith(volumes: newVolumes);
  }

  /// Toggles the mute state for a specific track
  MixerState toggleMute(String trackName) {
    final newMutedTracks = Map<String, bool>.from(mutedTracks);
    newMutedTracks[trackName] = !(mutedTracks[trackName] ?? false);
    return copyWith(mutedTracks: newMutedTracks);
  }

  /// Sets the mute state for a specific track
  MixerState setMute(String trackName, bool muted) {
    final newMutedTracks = Map<String, bool>.from(mutedTracks);
    newMutedTracks[trackName] = muted;
    return copyWith(mutedTracks: newMutedTracks);
  }

  /// Gets the effective volume for a track (0.0 if muted)
  double getEffectiveVolume(String trackName) {
    final isMuted = mutedTracks[trackName] ?? false;
    final volume = volumes[trackName] ?? 1.0;
    return isMuted ? 0.0 : volume;
  }

  /// Checks if a track is muted
  bool isMuted(String trackName) {
    return mutedTracks[trackName] ?? false;
  }

  /// Gets the volume for a track
  double getVolume(String trackName) {
    return volumes[trackName] ?? 1.0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MixerState &&
        _mapsEqual(other.volumes, volumes) &&
        _mapsEqual(other.mutedTracks, mutedTracks);
  }

  bool _mapsEqual<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(volumes, mutedTracks);
  }

  @override
  String toString() {
    return 'MixerState(volumes: $volumes, mutedTracks: $mutedTracks)';
  }
}
