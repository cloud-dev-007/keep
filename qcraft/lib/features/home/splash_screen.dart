import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qcraft/features/home/screens/home_screen.dart';
import 'package:sprung/sprung.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(1800.ms).then(
      ((_) => Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomeScreen(),
            ),
          )),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/logo.svg",
              width: 30,
            )
                .animate()
                .slideX(begin: -1, curve: Sprung(), duration: 600.ms)
                .fade(delay: 100.ms)
                .blurXY(begin: 20, end: 0),
            SizedBox(
              width: 20,
            ),
            Text(
              "qCraft",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  fontFamily: "Proxima-Nova"),
            )
                .animate()
                .slideX(begin: -1.5, curve: Sprung(28), duration: 1600.ms)
                .fade(delay: 200.ms)
                .blurXY(begin: 12, end: 0, duration: 1200.ms),
          ],
        ),
      ),
    );
  }
}
