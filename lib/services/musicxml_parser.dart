import 'package:xml/xml.dart';

/// Simplified note data structure for rendering
class ParsedNote {
  final String step; // C, D, E, F, G, A, B
  final int octave;
  final String type; // quarter, half, whole, eighth
  final List<String> lyrics;
  final bool hasDot;
  final String? accidental; // sharp, flat, natural
  final bool isRest;
  
  ParsedNote({
    required this.step,
    required this.octave,
    required this.type,
    this.lyrics = const [],
    this.hasDot = false,
    this.accidental,
    this.isRest = false,
  });
  
  /// Get the vertical position on the staff (0 = middle line)
  int get staffPosition {
    const stepValues = {'C': 0, 'D': 1, 'E': 2, 'F': 3, 'G': 4, 'A': 5, 'B': 6};
    final basePosition = stepValues[step] ?? 0;
    final octaveOffset = (octave - 4) * 7; // Each octave is 7 steps
    return basePosition + octaveOffset;
  }
  
  /// Determine if note belongs on treble or bass clef
  /// Middle C (C4) and above go on treble, below go on bass
  bool get isTrebleClef {
    return octave >= 4 && (octave > 4 || staffPosition >= 0);
  }
}

/// Simplified measure data
class ParsedMeasure {
  final List<ParsedNote> trebleNotes;
  final List<ParsedNote> bassNotes;
  final String? clef; // G or F
  final int? fifths; // Key signature (-7 to 7)
  final String? timeSignature; // e.g., "3/4"
  
  ParsedMeasure({
    required this.trebleNotes,
    required this.bassNotes,
    this.clef,
    this.fifths,
    this.timeSignature,
  });
}

/// Service for parsing MusicXML files
class MusicXMLParser {
  /// Parse a MusicXML string and return simplified measure data
  List<ParsedMeasure> parse(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);
    final measures = <ParsedMeasure>[];
    
    String? currentClef;
    int? currentFifths;
    String? currentTimeSignature;
    
    // Find all measure elements
    final measureElements = document.findAllElements('measure');
    
    for (final measureElement in measureElements) {
      final allNotes = <ParsedNote>[];
      
      // Check for attributes (clef, key, time signature)
      final attributes = measureElement.findElements('attributes').firstOrNull;
      if (attributes != null) {
        // Get clef
        final clefElement = attributes.findElements('clef').firstOrNull;
        if (clefElement != null) {
          final sign = clefElement.findElements('sign').firstOrNull?.innerText;
          currentClef = sign;
        }
        
        // Get key signature
        final keyElement = attributes.findElements('key').firstOrNull;
        if (keyElement != null) {
          final fifthsText = keyElement.findElements('fifths').firstOrNull?.innerText;
          if (fifthsText != null) {
            currentFifths = int.tryParse(fifthsText);
          }
        }
        
        // Get time signature
        final timeElement = attributes.findElements('time').firstOrNull;
        if (timeElement != null) {
          final beats = timeElement.findElements('beats').firstOrNull?.innerText;
          final beatType = timeElement.findElements('beat-type').firstOrNull?.innerText;
          if (beats != null && beatType != null) {
            currentTimeSignature = '$beats/$beatType';
          }
        }
      }
      
      // Parse notes in this measure
      final noteElements = measureElement.findElements('note');
      for (final noteElement in noteElements) {
        // Check if it's a rest
        final isRest = noteElement.findElements('rest').isNotEmpty;
        
        if (isRest) {
          final type = noteElement.findElements('type').firstOrNull?.innerText;
          if (type != null) {
            // Add rest with default position (middle C)
            allNotes.add(ParsedNote(
              step: 'C',
              octave: 4,
              type: type,
              isRest: true,
            ));
          }
          continue;
        }
        
        final pitch = noteElement.findElements('pitch').firstOrNull;
        if (pitch == null) continue;
        
        final step = pitch.findElements('step').firstOrNull?.innerText;
        final octaveText = pitch.findElements('octave').firstOrNull?.innerText;
        final type = noteElement.findElements('type').firstOrNull?.innerText;
        
        if (step == null || octaveText == null || type == null) continue;
        
        final octave = int.tryParse(octaveText);
        if (octave == null) continue;
        
        // Check for dot
        final hasDot = noteElement.findElements('dot').isNotEmpty;
        
        // Get all lyrics
        final lyrics = <String>[];
        final lyricElements = noteElement.findElements('lyric');
        for (final lyricElement in lyricElements) {
          final text = lyricElement.findElements('text').firstOrNull?.innerText;
          if (text != null && text.isNotEmpty) {
            lyrics.add(text);
          }
        }
        
        // Check for accidental
        String? accidental;
        final accidentalElement = pitch.findElements('alter').firstOrNull;
        if (accidentalElement != null) {
          final alterValue = int.tryParse(accidentalElement.innerText);
          if (alterValue == 1) accidental = 'sharp';
          if (alterValue == -1) accidental = 'flat';
        }
        
        allNotes.add(ParsedNote(
          step: step,
          octave: octave,
          type: type,
          lyrics: lyrics,
          hasDot: hasDot,
          accidental: accidental,
        ));
      }
      
      // Separate notes into treble and bass clef
      final trebleNotes = allNotes.where((note) => note.isTrebleClef).toList();
      final bassNotes = allNotes.where((note) => !note.isTrebleClef).toList();
      
      measures.add(ParsedMeasure(
        trebleNotes: trebleNotes,
        bassNotes: bassNotes,
        clef: currentClef,
        fifths: currentFifths,
        timeSignature: currentTimeSignature,
      ));
    }
    
    return measures;
  }
}
