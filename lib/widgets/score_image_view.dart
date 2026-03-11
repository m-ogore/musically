import 'package:flutter/material.dart';
import '../models/score_bounds.dart';

/// Displays a score image with bounding-box highlights.
///
/// Draws overlays for the active system, measure, and beat.
class ScoreImageView extends StatelessWidget {
  final String imagePath;
  final ScoreBoundsData? boundsData;
  final SystemBounds? activeSystem;
  final MeasureBounds? activeMeasure;
  final BeatBounds? activeBeat;
  final int fallbackSystemIndex;
  final int fallbackTotalSystems;
  final bool isActive;

  const ScoreImageView({
    super.key,
    required this.imagePath,
    this.boundsData,
    this.activeSystem,
    this.activeMeasure,
    this.activeBeat,
    this.fallbackSystemIndex = -1,
    this.fallbackTotalSystems = 0,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20.0),
            minScale: 0.1,
            maxScale: 4.0,
            child: Center(
              child: Stack(
                children: [
                  // Score Image
                  Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Score image not found:\n$imagePath',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                  ),

                  // Bounding Box Overlay (Or Fallback)
                  if (isActive)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: LayoutBuilder(
                          builder: (context, imgConstraints) {
                            return CustomPaint(
                              painter: _BoundsHighlightPainter(
                                boundsData: boundsData,
                                activeSystem: activeSystem,
                                activeMeasure: activeMeasure,
                                activeBeat: activeBeat,
                                fallbackSystemIndex: fallbackSystemIndex,
                                fallbackTotalSystems: fallbackTotalSystems,
                                renderWidth: imgConstraints.maxWidth,
                                renderHeight: imgConstraints.maxHeight,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BoundsHighlightPainter extends CustomPainter {
  final ScoreBoundsData? boundsData;
  final SystemBounds? activeSystem;
  final MeasureBounds? activeMeasure;
  final BeatBounds? activeBeat;
  final int fallbackSystemIndex;
  final int fallbackTotalSystems;
  final double renderWidth;
  final double renderHeight;

  _BoundsHighlightPainter({
    this.boundsData,
    this.activeSystem,
    this.activeMeasure,
    this.activeBeat,
    required this.fallbackSystemIndex,
    required this.fallbackTotalSystems,
    required this.renderWidth,
    required this.renderHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (boundsData != null) {
      _paintExplicitBounds(canvas, size);
    } else {
      _paintFallbackSystemSlice(canvas, size);
    }
  }

  void _paintFallbackSystemSlice(Canvas canvas, Size size) {
    if (fallbackSystemIndex < 0 || fallbackTotalSystems <= 0) return;

    const double headerRatio = 0.13;
    final double headerHeight = renderHeight * headerRatio;
    final double usableHeight = renderHeight - headerHeight;
    final double systemHeight = usableHeight / fallbackTotalSystems;
    final double startY = headerHeight + (fallbackSystemIndex * systemHeight);

    final Paint paint = Paint()
      ..color = const Color.fromRGBO(33, 150, 243, 0.2) // ~20% opacity blue
      ..style = PaintingStyle.fill;

    final double marginX = renderWidth * 0.05;
    final rect = Rect.fromLTWH(0, startY, renderWidth, systemHeight);
    canvas.drawRect(rect, paint);
    
    final borderPaint = Paint()
      ..color = const Color.fromRGBO(33, 150, 243, 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawLine(Offset(marginX, startY), Offset(renderWidth - marginX, startY), borderPaint);
    canvas.drawLine(Offset(marginX, startY + systemHeight), Offset(renderWidth - marginX, startY + systemHeight), borderPaint);
  }

  void _paintExplicitBounds(Canvas canvas, Size size) {
    if (boundsData == null) return;
    final data = boundsData!;

    final double scaleX = renderWidth / data.imageWidth;
    final double scaleY = renderHeight / data.imageHeight;

    // 1. Highlight the entire active system (line of music)
    if (activeSystem != null) {
      final Paint systemPaint = Paint()
        ..color = const Color.fromRGBO(33, 150, 243, 0.1) // 10% blue
        ..style = PaintingStyle.fill;
        
      final Rect systemRect = Rect.fromLTWH(
        activeSystem!.x * scaleX,
        activeSystem!.y * scaleY,
        activeSystem!.width * scaleX,
        activeSystem!.height * scaleY,
      );
      canvas.drawRect(systemRect, systemPaint);

      final systemBorder = Paint()
        ..color = const Color.fromRGBO(33, 150, 243, 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Top and bottom borders for the system
      canvas.drawLine(systemRect.topLeft, systemRect.topRight, systemBorder);
      canvas.drawLine(systemRect.bottomLeft, systemRect.bottomRight, systemBorder);
    }

    // 2. Highlight the active measure
    // if (activeMeasure != null) {
    //   final Paint measurePaint = Paint()
    //     ..color = const Color.fromRGBO(33, 150, 243, 0.1) // Additional 10% blue
    //     ..style = PaintingStyle.fill;
    //
    //   final Rect measureRect = Rect.fromLTWH(
    //     activeMeasure!.x * scaleX,
    //     activeMeasure!.y * scaleY,
    //     activeMeasure!.width * scaleX,
    //     activeMeasure!.height * scaleY,
    //   );
    //   // canvas.drawRect(measureRect, measurePaint);
    // }

    // 3. Highlight the active beat / chord slice
    if (activeBeat != null) {
      final Paint beatPaint = Paint()
        ..color = const Color.fromRGBO(255, 193, 7, 0.5) // 50% Amber for the active note/chord
        ..style = PaintingStyle.fill;

      final Rect beatRect = Rect.fromLTWH(
        activeBeat!.x * scaleX,
        activeBeat!.y * scaleY,
        activeBeat!.width * scaleX,
        activeBeat!.height * scaleY,
      );
      canvas.drawRect(beatRect, beatPaint);
      
      final Paint beatBorder = Paint()
        ..color = const Color.fromRGBO(255, 152, 0, 0.8) // Orange border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
        
      canvas.drawRect(beatRect, beatBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _BoundsHighlightPainter oldDelegate) {
    return oldDelegate.activeSystem != activeSystem ||
        oldDelegate.activeMeasure != activeMeasure ||
        oldDelegate.activeBeat != activeBeat ||
        oldDelegate.fallbackSystemIndex != fallbackSystemIndex ||
        oldDelegate.fallbackTotalSystems != fallbackTotalSystems ||
        oldDelegate.renderWidth != renderWidth ||
        oldDelegate.renderHeight != renderHeight;
  }
}
