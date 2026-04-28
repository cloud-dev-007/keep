import 'package:flutter/cupertino.dart';

import '../../../../core/constants/app_colors.dart';

class QuizSetupWidget extends StatelessWidget {
  final Widget child;
  final String leading;
  final String? trailing;

  const QuizSetupWidget(
      {super.key, required this.child, required this.leading, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leading,
              style: TextStyle(
                fontFamily: "Proxima Nova",
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              trailing ?? "",
              style: TextStyle(
                fontFamily: "Proxima Nova",
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 12.0,
        ),
        child,
        SizedBox(
          height: 24.0,
        ),
      ],
    );
  }
}
