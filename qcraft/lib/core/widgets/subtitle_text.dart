import 'package:flutter/cupertino.dart';

class SubtitleText extends StatelessWidget {
  final String text;

  const SubtitleText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
          fontFamily: "Proxima Nova",
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 2),
    );
  }
}
