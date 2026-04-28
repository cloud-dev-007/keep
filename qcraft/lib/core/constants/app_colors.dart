import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF3252B3);
  static const Color secondary = Color(0xFF26A69A);
  static const Color orange = Color(0xFFF67D00);
  static const Color purple = Color(0xFFBE42F1);
  static const Color bg = Color(0xFFF5F5F5);
  static const Color completed = Color(0xFF04B3E0);
  static const Color kora = Color(0xFF0062F6);

  static const Color error = Color(0xFFD53833);
  static const Color text = Color(0xFF06090C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFA8A8A8);
  static const Color grey = Color(0xFF808080);
  static const Color onboardingBg = Color(0xFF283B73);
  static const Color shade100 = Color.fromRGBO(50, 82, 179, .2);

  static MaterialColor mainColor = const MaterialColor(0xFF3252B3, <int, Color>{
    50: Color.fromRGBO(50, 82, 179, .1),
    100: Color.fromRGBO(50, 82, 179, .2),
    200: Color.fromRGBO(50, 82, 179, .3),
    300: Color.fromRGBO(50, 82, 179, .4),
    400: Color.fromRGBO(50, 82, 179, .5),
    500: Color(0xFF3252B3), // The main color
    600: Color.fromRGBO(50, 82, 179, .7),
    700: Color.fromRGBO(50, 82, 179, .8),
    800: Color.fromRGBO(50, 82, 179, .9),
    900: Color.fromRGBO(50, 82, 179, 1),
  });
}
