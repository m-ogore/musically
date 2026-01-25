import 'package:flutter/material.dart';
import '../models/hymn.dart';

/// Card widget for displaying a hymn in a list or grid
class HymnCard extends StatelessWidget {
  final Hymn hymn;
  final VoidCallback onTap;

  const HymnCard({
    super.key,
    required this.hymn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.music_note,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title and Number
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hymn.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${hymn.id}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Author
              Text(
                hymn.author,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Play button
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.play_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
