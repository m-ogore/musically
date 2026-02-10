import 'package:flutter/material.dart';

class ScoreImageView extends StatelessWidget {
  final String imagePath;

  const ScoreImageView({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Ensure a clean background for music scores
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20.0),
        minScale: 0.1,
        maxScale: 4.0,
        child: Center(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image, size: 64, color: Colors.grey),
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
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}
