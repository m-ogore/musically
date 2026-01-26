import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A widget that renders a single system of Grand Staff music
/// (Treble clef staff above Bass clef staff)
class SystemWidget extends StatelessWidget {
  final Map<String, dynamic> systemData;
  final bool isFirstSystem; // Used to trigger Time Signature and Key Signature
  final Duration? currentPosition;
  final bool highlight;
  final bool showBorder;
  final bool showBackground;

  const SystemWidget({
    super.key,
    required this.systemData,
    this.isFirstSystem = false,
    this.currentPosition,
    this.highlight = false,
    this.showBorder = true,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Handle cases where width is infinite (unconstrained)
        final drawWidth = availableWidth.isFinite ? availableWidth : 800.0;

        return Container(
          margin: EdgeInsets.symmetric(vertical: showBorder ? 8 : 0),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          decoration: BoxDecoration(
            color: highlight 
                ? Colors.blue.shade50 
                : (showBackground ? const Color(0xFFFFFDF7) : Colors.transparent),
            border: highlight
                ? Border.all(color: Colors.blue, width: 2)
                : (showBorder ? Border.all(color: Colors.grey.shade300) : null),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            // Use Clip.none to ensure notes on high/low ledger lines aren't cut off
            painter: GrandStaffPainter(
              systemData: systemData,
              showTimeSignature: isFirstSystem,
              currentPosition: currentPosition ?? Duration.zero,
              highlight: highlight,
            ),
            size: Size(drawWidth, 260),
          ),
        );
      },
    );
  }
}

class GrandStaffPainter extends CustomPainter {
  final Map<String, dynamic> systemData;
  final bool showTimeSignature;
  final Duration currentPosition;
  final bool highlight;

  // Layout Constants (Refined for professional high-density scaling)
  static const double lineSpacing = 10.0;
  static const double trebleTop = 30.0;
  static const double bassTop = 190.0; // Massive 130px gap to ensure zero overlap
  static const double leftMargin = 60.0;
  static const double rightMargin = 20.0;

  GrandStaffPainter({
    required this.systemData,
    this.showTimeSignature = false,
    this.currentPosition = Duration.zero,
    this.highlight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.2;

    _drawStaffLines(canvas, size, trebleTop, paint);
    _drawStaffLines(canvas, size, bassTop, paint);
    _drawBrace(canvas);
    _drawClefs(canvas);

    // Draw Key Signature if present
    if (systemData.containsKey('keySignature')) {
      final key = systemData['keySignature'];
      _drawKeySignature(canvas, key, trebleTop, isTreble: true);
      _drawKeySignature(canvas, key, bassTop, isTreble: false);
    }
    
    // Draw Time Signature (Only on the first system)
    if (showTimeSignature && systemData.containsKey('timeSignature')) {
      _drawTimeSignature(canvas, systemData['timeSignature']);
    }

    _drawMeasures(canvas, size);
  }

  void _drawStaffLines(Canvas canvas, Size size, double top, Paint paint) {
    for (int i = 0; i < 5; i++) {
      final y = top + (i * lineSpacing);
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width - rightMargin, y), paint);
    }
  }

  void _drawClefs(Canvas canvas) {
    // Treble Clef: Scaled for elegance
    _drawText(
      canvas, 
      '\u{1D11E}', // 𝄞
      Offset(leftMargin - 45, trebleTop - 18), 
      fontSize: 70,
    );

    // Bass Clef: Scaled for elegance
    _drawText(
      canvas, 
      '\u{1D122}', // 𝄢
      Offset(leftMargin - 42, bassTop - 8), 
      fontSize: 60,
    );
  }

  void _drawKeySignature(Canvas canvas, String key, double staffTop, {required bool isTreble}) {
    final accidentals = _getKeyAccidentals(key, isTreble);
    double x = leftMargin + 5;
    for (var acc in accidentals) {
      final y = staffTop + (acc['lineOffset'] * (lineSpacing / 2));
      _drawText(canvas, acc['symbol'], Offset(x, y - 10), fontSize: 26);
      x += 12;
    }
  }

  void _drawTimeSignature(Canvas canvas, String time) {
    final parts = time.split('/');
    if (parts.length == 2) {
      final xPos = leftMargin + (systemData.containsKey('keySignature') ? 55 : 15); 

      void drawSig(double top) {
        _drawText(canvas, parts[0], Offset(xPos, top - 4), fontSize: 24, fontWeight: FontWeight.bold);
        _drawText(canvas, parts[1], Offset(xPos, top + 18), fontSize: 24, fontWeight: FontWeight.bold);
      }

      drawSig(trebleTop);
      drawSig(bassTop);
    }
  }

  void _drawMeasures(Canvas canvas, Size size) {
    final trebleData = systemData['treble'] ?? {};
    final bassData = systemData['bass'] ?? {};

    // Voice mapping for choral four-part harmony (Soprano/Alto on top, Tenor/Bass on bottom)
    final voices = {
      'soprano': {'data': trebleData['soprano']?['measures'] ?? [], 'top': trebleTop, 'up': true, 'isTreble': true},
      'alto': {'data': trebleData['alto']?['measures'] ?? [], 'top': trebleTop, 'up': false, 'isTreble': true},
      'tenor': {'data': bassData['tenor']?['measures'] ?? [], 'top': bassTop, 'up': true, 'isTreble': false},
      'bass': {'data': bassData['bass']?['measures'] ?? [], 'top': bassTop, 'up': false, 'isTreble': false},
    };

    int maxMeasures = 0;
    voices.forEach((_, v) => maxMeasures = math.max(maxMeasures, (v['data'] as List).length));
    if (maxMeasures == 0) return;

    final contentStart = leftMargin + (showTimeSignature ? 85 : 45);
    final mWidth = (size.width - contentStart - rightMargin) / maxMeasures;

    for (int i = 0; i < maxMeasures; i++) {
      final x = contentStart + (i * mWidth);
      _drawBarline(canvas, x);
      
      voices.forEach((name, config) {
        final measures = config['data'] as List;
        if (i < measures.length) {
          _drawMeasureNotes(
            canvas, measures[i], x, mWidth, 
            config['top'] as double, 
            config['isTreble'] as bool, 
            stemUp: config['up'] as bool
          );
        }
      });
    }
    _drawBarline(canvas, size.width - rightMargin);
  }

  void _drawMeasureNotes(Canvas canvas, List<dynamic> notes, double mX, double mWidth, double staffTop, bool isTreble, {required bool stemUp}) {
    if (notes.isEmpty) return;
    final spacing = mWidth / (notes.length + 1);

    for (int i = 0; i < notes.length; i++) {
      final item = notes[i];
      final x = mX + ((i + 1) * spacing);

      if (item['note'] == 'rest') {
        _drawRest(canvas, x, staffTop, item['duration']);
        continue;
      }

      final info = _parseNote(item['note']);
      final y = _calculateNoteY(info, staffTop, isTreble);
      
      final timestamp = Duration(milliseconds: item['timestamp'] ?? 0);
      final isPlaying = currentPosition >= timestamp && 
                       currentPosition < timestamp + const Duration(milliseconds: 500);

      _drawNoteHead(canvas, x, y, item, stemUp, staffTop, isTreble, isPlaying: isPlaying);
      _drawLedgerLines(canvas, x, y, staffTop);
    }
  }

  double _calculateNoteY(Map<String, dynamic> info, double staffTop, bool isTreble) {
    const pitchMap = {'C': 0, 'D': 1, 'E': 2, 'F': 3, 'G': 4, 'A': 5, 'B': 6};
    final pitchVal = pitchMap[info['pitch']] ?? 0;
    final octave = info['octave'] as int;

    // Standardized centers: B4 for Treble staff, D3 for Bass staff
    final centerOctave = isTreble ? 4 : 3;
    final centerPitch = isTreble ? 6 : 1; 
    
    final stepsFromMiddle = (octave - centerOctave) * 7 + (pitchVal - centerPitch);
    final middleLineY = staffTop + (lineSpacing * 2);
    return middleLineY - (stepsFromMiddle * lineSpacing / 2);
  }

  void _drawNoteHead(Canvas canvas, double x, double y, Map<String, dynamic> item, bool stemUp, double staffTop, bool isTreble, {bool isPlaying = false}) {
    final color = isPlaying ? Colors.blue : Colors.black;
    final paint = Paint()..color = color;
    final isHollow = item['duration'] == 'whole' || item['duration'] == 'half';

    if (isHollow) {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 9, height: 6.8), paint..style = PaintingStyle.stroke..strokeWidth = 1.4);
    } else {
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 9, height: 6.8), paint..style = PaintingStyle.fill);
    }

    // Stem Logic (Micro-scaled)
    if (item['duration'] != 'whole') {
      final stemDir = stemUp ? -1 : 1;
      final stemX = stemUp ? x + 4.0 : x - 4.0;
      canvas.drawLine(
        Offset(stemX, y), 
        Offset(stemX, y + (24 * stemDir)), 
        Paint()..color = color..strokeWidth = 1.0
      );
    }

    // Lyric Placement (Standard Hymnal Position: between Treble and Bass staves)
    // Supports single 'lyric' or multiple 'lyrics' (stanzas)
    if (isTreble && stemUp) {
      final List<String> stanzas = [];
      if (item['lyrics'] != null && item['lyrics'] is List) {
        stanzas.addAll(List<String>.from(item['lyrics']));
      } else if (item['lyric'] != null) {
        stanzas.add(item['lyric'] as String);
      }

      if (stanzas.isNotEmpty) {
        // Vertical center of the inter-staff gap
        const double gapBottom = bassTop;
        const double gapTop = trebleTop + (lineSpacing * 4);
        const double gapMiddle = (gapTop + gapBottom) / 2;
        
        // Stack lyrics vertically centered around the gapMiddle
        const double stanzaHeight = 15.0;
        final double totalHeight = (stanzas.length - 1) * stanzaHeight;
        double currentY = gapMiddle - (totalHeight / 2) - 6;

        for (var lyric in stanzas) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: lyric, 
              style: TextStyle(
                fontSize: 12.0, 
                fontWeight: FontWeight.w600,
                color: isPlaying ? Colors.blue : Colors.black87,
                fontFamily: 'serif',
              )
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          
          // Center the text horizontally under the note
          final double textX = x - (textPainter.width / 2);
          textPainter.paint(canvas, Offset(textX, currentY));
          currentY += stanzaHeight;
        }
      }
    }
  }

  void _drawLedgerLines(Canvas canvas, double x, double y, double staffTop) {
    final staffBottom = staffTop + (lineSpacing * 4);
    final paint = Paint()..color = Colors.black..strokeWidth = 1.2;
    
    // Above staff
    if (y < staffTop - 2) {
      for (double ly = staffTop - lineSpacing; ly >= y - 2; ly -= lineSpacing) {
        canvas.drawLine(Offset(x - 10, ly), Offset(x + 10, ly), paint);
      }
    } 
    // Below staff
    else if (y > staffBottom + 2) {
      for (double ly = staffBottom + lineSpacing; ly <= y + 2; ly += lineSpacing) {
        canvas.drawLine(Offset(x - 10, ly), Offset(x + 10, ly), paint);
      }
    }
  }

  void _drawBarline(Canvas canvas, double x) {
    // Single continuous line for Grand Staff
    canvas.drawLine(
      Offset(x, trebleTop), 
      Offset(x, bassTop + (lineSpacing * 4)), 
      Paint()..strokeWidth = 1.5
    );
  }

  void _drawBrace(Canvas canvas) {
    final path = Path()
      ..moveTo(leftMargin - 55, trebleTop)
      ..quadraticBezierTo(
        leftMargin - 75, 
        (trebleTop + bassTop + lineSpacing * 4) / 2, 
        leftMargin - 55, 
        bassTop + lineSpacing * 4
      );
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5);
  }

  List<Map<String, dynamic>> _getKeyAccidentals(String key, bool isTreble) {
    if (key == 'G') {
      return isTreble 
          ? [{'symbol': '♯', 'lineOffset': 0.0}] // F5
          : [{'symbol': '♯', 'lineOffset': 1.0}]; // F3
    } else if (key == 'Eb') {
      return isTreble 
          ? [
              {'symbol': '♭', 'lineOffset': 2.0}, // B4
              {'symbol': '♭', 'lineOffset': 0.5}, // E5
              {'symbol': '♭', 'lineOffset': 2.5}, // A4
            ]
          : [
              {'symbol': '♭', 'lineOffset': 3.0}, // B2
              {'symbol': '♭', 'lineOffset': 1.5}, // E3
              {'symbol': '♭', 'lineOffset': 3.5}, // A2
            ];
    }
    return [];
  }

  Map<String, dynamic> _parseNote(String note) {
    final pitch = note[0];
    final octave = int.parse(note.replaceAll(RegExp(r'[^0-9]'), ''));
    return {'pitch': pitch, 'octave': octave};
  }

  void _drawRest(Canvas canvas, double x, double y, String dur) {
    String sym = dur == 'quarter' ? '𝄽' : '𝄼';
    _drawText(canvas, sym, Offset(x - 6, y + 12), fontSize: 26);
  }

  void _drawText(Canvas canvas, String text, Offset pos, {double fontSize = 14, FontWeight fontWeight = FontWeight.normal, Color color = Colors.black}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text, 
        style: TextStyle(
          fontSize: fontSize, 
          fontWeight: fontWeight, 
          color: color, 
          fontFamily: 'serif',
        )
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, pos);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}