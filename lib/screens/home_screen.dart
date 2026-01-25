import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../providers/hymn_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/hymn_card.dart';
import 'hymn_detail_screen.dart';

/// Home screen displaying all available hymns
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        title: const Text('Musically'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      body: Consumer<HymnProvider>(
        builder: (context, hymnProvider, child) {
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

          return ResponsiveBuilder(
            builder: (context, sizingInformation) {
              // Determine layout based on screen size
              final isMobile = sizingInformation.screenSize.width < 600;
              
              if (isMobile) {
                return _buildListView(hymnProvider);
              } else {
                return _buildGridView(hymnProvider, sizingInformation);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildListView(HymnProvider hymnProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hymnProvider.hymns.length,
      itemBuilder: (context, index) {
        final hymn = hymnProvider.hymns[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 200,
            child: HymnCard(
              hymn: hymn,
              onTap: () => _navigateToDetail(hymn.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(HymnProvider hymnProvider, SizingInformation sizingInformation) {
    // Determine number of columns based on screen width
    int crossAxisCount = 2;
    if (sizingInformation.screenSize.width > 900) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: hymnProvider.hymns.length,
      itemBuilder: (context, index) {
        final hymn = hymnProvider.hymns[index];
        return HymnCard(
          hymn: hymn,
          onTap: () => _navigateToDetail(hymn.id),
        );
      },
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
      applicationName: 'Musically',
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
          '• Responsive design for mobile and tablet',
        ),
      ],
    );
  }
}
