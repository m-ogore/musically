import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/hymn_provider.dart';
import '../providers/player_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/hymn_tile.dart';
import '../delegates/hymn_search_delegate.dart';
import 'hymn_detail_screen.dart';

/// Home screen displaying all available hymns
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load hymns when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HymnProvider>().loadHymns();
      context.read<PlayerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'SDA Hymn Mixer' : 'Favorites'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(context),
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      body: Consumer2<HymnProvider, FavoritesProvider>(
        builder: (context, hymnProvider, favoritesProvider, child) {
          if (hymnProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (hymnProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    hymnProvider.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => hymnProvider.loadHymns(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (hymnProvider.hymns.isEmpty) {
            return const Center(
              child: Text('No hymns available'),
            );
          }

          final hymnsToDisplay = _currentIndex == 0 
              ? hymnProvider.hymns 
              : hymnProvider.hymns.where((h) => favoritesProvider.isFavorite(h.id)).toList();

          if (_currentIndex == 1 && hymnsToDisplay.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.favorite_border, size: 64, color: Theme.of(context).colorScheme.outline),
                   const SizedBox(height: 16),
                   Text(
                     'No favorites yet',
                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                       color: Theme.of(context).colorScheme.onSurfaceVariant,
                     ),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     'Tap the heart icon on a hymn to save it here.',
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: Theme.of(context).colorScheme.outline,
                     ),
                   ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: hymnsToDisplay.length,
            itemBuilder: (context, index) {
              final hymn = hymnsToDisplay[index];
              return HymnTile(
                hymn: hymn,
                onTap: () => _navigateToDetail(hymn.id),
              );
            },
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'All Hymns',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context) {
    final hymnProvider = context.read<HymnProvider>();
    showSearch(
      context: context,
      delegate: HymnSearchDelegate(
        hymns: hymnProvider.hymns,
        onHymnSelected: (hymnId) {
          _navigateToDetail(hymnId);
        },
      ),
    );
  }

  void _navigateToDetail(String hymnId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HymnDetailScreen(hymnId: hymnId),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SDA Hymn Mixer',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.music_note, size: 48),
      children: [
        const Text(
          'A high-performance hymn practice app with multi-track audio mixing.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• Synchronized multi-track playback\n'
          '• Individual volume control for each voice part\n'
          '• Lyrics and musical notation views\n'
          '• Responsive design for mobile and tablet\n'
          '• Offline track downloads',
        ),
      ],
    );
  }
}
