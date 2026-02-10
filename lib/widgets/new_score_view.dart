import 'package:flutter/material.dart';

class NewScoreView extends StatelessWidget {
  final Map<String, dynamic> data;

  const NewScoreView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 64, color: Colors.blueGrey),
          SizedBox(height: 16),
          Text(
            'New Score Rendering View',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Coming soon...'),
        ],
      ),
    );
  }
}
