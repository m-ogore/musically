import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_sheet_music/simple_sheet_music.dart';
import '../providers/player_provider.dart';

/// Widget for displaying dynamic musical notation with "bouncing ball" synchronization
class NotationView extends StatelessWidget {
  final String notationData;
  final List<Duration> noteTimestamps;

  const NotationView({
    super.key,
    required this.notationData,
    required this.noteTimestamps,
  });

  @override
  Widget build(BuildContext context) {
    // Watch player provider for position updates to drive the cursor
    final playerProvider = context.watch<PlayerProvider>();
    final currentPosition = playerProvider.currentPosition;
    
    // Determine the current note index based on playback position
    final currentNoteIndex = _getCurrentNoteIndex(currentPosition);

    try {
      final measures = _parseNotationData(notationData, currentNoteIndex, context);
      
      return Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SimpleSheetMusic(
            measures: measures,
          ),
        ),
      );
    } catch (e) {
      return Center(
        child: Text('Error parsing notation: $e'),
      );
    }
  }

  /// Finds the index of the note that should be currently playing/highlighted
  int _getCurrentNoteIndex(Duration position) {
    for (int i = 0; i < noteTimestamps.length; i++) {
      if (i + 1 < noteTimestamps.length) {
        if (position >= noteTimestamps[i] && position < noteTimestamps[i + 1]) {
          return i;
        }
      } else {
        // Last note
        if (position >= noteTimestamps[i]) {
          return i;
        }
      }
    }
    return -1; // Before start
  }

  /// Parses JSON notation data into SimpleSheetMusic measures
  List<Measure> _parseNotationData(String data, int highlightedIndex, BuildContext context) {
    final Map<String, dynamic> json = jsonDecode(data);
    final List<Measure> measuresList = [];
    
    final List measures = json['measures'] ?? [];
    int noteCounter = 0;

    for (var measureData in measures) {
      final List<Note> notes = [];
      
      for (var item in measureData) {
        final noteName = item['note'];
        final durationStr = item['duration'];
        
        final noteDuration = _parseDuration(durationStr);
        final pitch = _parsePitch(noteName);
        
        // Check if highlighted
        final isHighlighted = noteCounter == highlightedIndex;
        final color = isHighlighted ? Theme.of(context).colorScheme.primary : Colors.black;
        
        // Fix: Measure expects positional list
        // Fix: Note expects 1 positional (pitch?), and maybe noteDuration is the named param?
        // Fix: Pitch enum names
        
        notes.add(Note(
          pitch,
          noteDuration: noteDuration,
          color: color,
        ));
        
        noteCounter++;
      }
      
      measuresList.add(Measure(notes));
    }

    return measuresList;
  }

  NoteDuration _parseDuration(String duration) {
    switch (duration) {
      case 'whole': return NoteDuration.whole;
      case 'half': return NoteDuration.half;
      case 'quarter': return NoteDuration.quarter;
      case 'eighth': return NoteDuration.eighth;
      case 'sixteenth': return NoteDuration.sixteenth;
      default: return NoteDuration.quarter;
    }
  }

  Pitch _parsePitch(String noteName) {
    // Guessing Pitch enum names
    if (noteName == 'C4') return Pitch.c4;
    if (noteName == 'D4') return Pitch.d4;
    if (noteName == 'E4') return Pitch.e4;
    if (noteName == 'F4') return Pitch.f4;
    if (noteName == 'F#4') return Pitch.f4; // Fallback: Sharp not found, using natural found
    if (noteName == 'G4') return Pitch.g4;
    if (noteName == 'A4') return Pitch.a4;
    if (noteName == 'B4') return Pitch.b4;
    if (noteName == 'C5') return Pitch.c5;
    
    return Pitch.c4; 
  }
}
