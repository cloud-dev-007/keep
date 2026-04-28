import 'package:flutter/material.dart';
import 'package:qcraft/config/themes.dart';

import 'features/home/splash_screen.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const QCraft());
}

class QCraft extends StatelessWidget {
  const QCraft({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'qCraft',
      theme: AppTheme.mainTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
