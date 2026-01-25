import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/hymn_provider.dart';
import 'providers/player_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MusicallyApp());
}

class MusicallyApp extends StatelessWidget {
  const MusicallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HymnProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: MaterialApp(
        title: 'SDA Hymn Mixer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
