import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'api/auth_store.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

/// Single shared API client. Plain top-level instead of get_it / Provider —
/// the app is small enough that a singleton is clearer.
final ApiClient apiClient = ApiClient();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore any persisted session before the first frame so we don't flash
  // the login screen for already-authenticated users.
  await authStore.load();
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
      home: const AuthGate(),
    );
  }
}

/// Swaps between the auth screen and the app based on authStore. Rebuilds
/// whenever the session changes (login, logout, or a 401-triggered clear).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authStore,
      builder: (context, _) {
        return authStore.isAuthenticated
            ? const HomeScreen()
            : const AuthScreen();
      },
    );
  }
}
