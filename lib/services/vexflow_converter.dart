import 'musicxml_parser.dart';

class VexFlowConverter {
  Map<String, dynamic> fromMusicXML(String xmlContent) {
    final parser = MusicXMLParser();
    final measures = parser.parse(xmlContent);
    
    if (measures.isEmpty) {
      return {'systems': []};
    }
    
    return {
      'keySignature': _getKeySignatureString(measures[0].fifths),
      'timeSignature': measures[0].timeSignature ?? '4/4',
      'systems': _convertMeasuresToSystems(measures),
    };
  }
  
  String _getKeySignatureString(int? fifths) {
    if (fifths == null || fifths == 0) return 'C';
    final keys = ['C', 'G', 'D', 'A', 'E', 'B', 'F#', 'C#'];
    final flatKeys = ['C', 'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb', 'Cb'];
    if (fifths > 0) {
      return fifths < keys.length ? keys[fifths] : 'C';
    } else {
      return (-fifths) < flatKeys.length ? flatKeys[-fifths] : 'C';
    }
  }
  
  List<Map<String, dynamic>> _convertMeasuresToSystems(List<ParsedMeasure> measures) {
    // Current approach: treating each measure as a potential system chunk
    // Use groupings logic if we want multiple measures per system, but for now 1 measure map per entry in 'systems' array
    // is what VexFlowRenderer iterates over? 
    // Wait, VexFlowRenderer iterates 'systems' and renders a full system row.
    // If we want multiple measures per system, we need to chunk them.
    // However, the current VexFlowRenderer loop seems to treat each item in 'systems' as a single system row.
    // And inside that system it has voices which contain 'measures'.
    // The JSON structure in HymnRepository uses:
    // system -> treble -> soprano -> measures [ [note, note], [note] ]
    // So 'systems' list is effectively "lines of notation".
    
    // We will group measures into systems (e.g. 2-3 measures per line)
    // For simplicity, let's say 2 measures per system for rendering on mobile.
    
    final systems = <Map<String, dynamic>>[];
    const measuresPerSystem = 2; // Adjustable
    
    for (int i = 0; i < measures.length; i += measuresPerSystem) {
      final end = (i + measuresPerSystem < measures.length) ? i + measuresPerSystem : measures.length;
      final systemMeasures = measures.sublist(i, end);
      
      systems.add({
        'keySignature': _getKeySignatureString(systemMeasures[0].fifths),
        'timeSignature': systemMeasures[0].timeSignature ?? '4/4',
        'treble': {
          'soprano': {
            'measures': systemMeasures.map((m) => _convertNotes(m.trebleNotes)).toList(),
          },
          'alto': {
            'measures': systemMeasures.map((m) => []).toList(), // Placeholder if we don't separate alto
          }
        },
        'bass': {
          'bass': {
            'measures': systemMeasures.map((m) => _convertNotes(m.bassNotes)).toList(),
          },
          'tenor': {
            'measures': systemMeasures.map((m) => []).toList(), // Placeholder
          }
        }
      });
    }
    
    return systems;
  }
  
  List<Map<String, dynamic>> _convertNotes(List<ParsedNote> notes) {
    if (notes.isEmpty) {
      // Return a whole rest if empty? Or just empty list.
      return [];
    }
    return notes.map((note) {
      return {
        'note': '${note.step}${note.octave}',
        'duration': note.type, // "quarter", "half", etc. match VexFlow map in bridge.html
        'lyrics': note.lyrics,
        // Accidental could be inferred from context or passed if we updated ParsedNote
        // parsing already handled accidental string?
      };
    }).toList();
  }
}
