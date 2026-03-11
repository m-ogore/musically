import 'dart:convert';

/// The root coordinate mapping for a specific hymn's image.
class ScoreBoundsData {
  final double imageWidth;
  final double imageHeight;
  final List<SystemBounds> systems;

  ScoreBoundsData({
    required this.imageWidth,
    required this.imageHeight,
    required this.systems,
  });

  factory ScoreBoundsData.fromJson(Map<String, dynamic> json) {
    return ScoreBoundsData(
      imageWidth: (json['imageWidth'] as num).toDouble(),
      imageHeight: (json['imageHeight'] as num).toDouble(),
      systems: (json['systems'] as List)
          .map((s) => SystemBounds.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
        'systems': systems.map((s) => s.toJson()).toList(),
      };
}

class SystemBounds {
  final int index;
  final double x;
  final double y;
  final double width;
  final double height;
  final List<MeasureBounds> measures;

  SystemBounds({
    required this.index,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.measures,
  });

  factory SystemBounds.fromJson(Map<String, dynamic> json) {
    final bounds = json['bounds'] as Map<String, dynamic>;
    return SystemBounds(
      index: json['index'] as int,
      x: (bounds['x'] as num).toDouble(),
      y: (bounds['y'] as num).toDouble(),
      width: (bounds['width'] as num).toDouble(),
      height: (bounds['height'] as num).toDouble(),
      measures: (json['measures'] as List)
          .map((m) => MeasureBounds.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'bounds': {
          'x': x,
          'y': y,
          'width': width,
          'height': height,
        },
        'measures': measures.map((m) => m.toJson()).toList(),
      };
}

class MeasureBounds {
  final int index;
  final double x;
  final double y;
  final double width;
  final double height;
  final List<BeatBounds> beats;

  MeasureBounds({
    required this.index,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.beats,
  });

  factory MeasureBounds.fromJson(Map<String, dynamic> json) {
    final bounds = json['bounds'] as Map<String, dynamic>;
    return MeasureBounds(
      index: json['index'] as int,
      x: (bounds['x'] as num).toDouble(),
      y: (bounds['y'] as num).toDouble(),
      width: (bounds['width'] as num).toDouble(),
      height: (bounds['height'] as num).toDouble(),
      beats: (json['beats'] as List)
          .map((b) => BeatBounds.fromJson(b))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'bounds': {
          'x': x,
          'y': y,
          'width': width,
          'height': height,
        },
        'beats': beats.map((b) => b.toJson()).toList(),
      };
}

class BeatBounds {
  final int timeMs;
  final int durationMs;
  final double x;
  final double y;
  final double width;
  final double height;

  BeatBounds({
    required this.timeMs,
    required this.durationMs,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BeatBounds.fromJson(Map<String, dynamic> json) {
    final bounds = json['bounds'] as Map<String, dynamic>;
    return BeatBounds(
      timeMs: json['timeMs'] as int,
      durationMs: json['durationMs'] as int,
      x: (bounds['x'] as num).toDouble(),
      y: (bounds['y'] as num).toDouble(),
      width: (bounds['width'] as num).toDouble(),
      height: (bounds['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'timeMs': timeMs,
        'durationMs': durationMs,
        'bounds': {
          'x': x,
          'y': y,
          'width': width,
          'height': height,
        },
      };
}
