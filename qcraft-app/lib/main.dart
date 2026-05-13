import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'screens/home_screen.dart';

/// Single shared API client. Plain top-level instead of get_it / Provider —
/// the app is small enough that a singleton is clearer.
final ApiClient apiClient = ApiClient();

void main() {
  runApp(const QCraftApp());
}

class QCraftApp extends StatelessWidget {
  const QCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF6750A4); // Material 3 default purple
    return MaterialApp(
      title: 'qCraft',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
