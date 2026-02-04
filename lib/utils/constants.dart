import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  // Track names
  static const String sopranoTrack = 'soprano';
  static const String altoTrack = 'alto';
  static const String tenorTrack = 'tenor';
  static const String bassTrack = 'bass';
  static const String instrumentalTrack = 'instrumental';

  static const List<String> allTracks = [
    sopranoTrack,
    altoTrack,
    tenorTrack,
    bassTrack,
    instrumentalTrack,
  ];

  // Track display names
  static const Map<String, String> trackDisplayNames = {
    sopranoTrack: 'Soprano',
    altoTrack: 'Alto',
    tenorTrack: 'Tenor',
    bassTrack: 'Bass',
    instrumentalTrack: 'Instrumental',
  };

  // Track colors for UI
  static const Map<String, Color> trackColors = {
    sopranoTrack: Color(0xFF9C27B0), // Purple
    altoTrack: Color(0xFF2196F3), // Blue
    tenorTrack: Color(0xFF4CAF50), // Green
    bassTrack: Color(0xFFFF9800), // Orange
    instrumentalTrack: Color(0xFF757575), // Gray
  };

  // Audio synchronization
  static const Duration syncTolerance = Duration(milliseconds: 30);
  static const Duration hardSyncTolerance = Duration(milliseconds: 200);
  static const Duration syncCheckInterval = Duration(milliseconds: 100);

  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;

  // Grid layout
  static const int mobileGridColumns = 1;
  static const int tabletGridColumns = 2;
  static const int desktopGridColumns = 3;

  // Seek controls
  static const Duration seekBackwardDuration = Duration(seconds: 10);
  static const Duration seekForwardDuration = Duration(seconds: 10);
}
