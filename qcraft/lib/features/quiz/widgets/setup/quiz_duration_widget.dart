import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_setup_widget.dart';

import '../../../../core/constants/app_colors.dart';

class QuizDurationWidget extends StatefulWidget {
  final Function(int? duration) onUpdate;

  const QuizDurationWidget({super.key, required this.onUpdate});

  @override
  State<QuizDurationWidget> createState() => _QuizDurationWidgetState();
}

class _QuizDurationWidgetState extends State<QuizDurationWidget> {
  String? text;

  int selectedIndex = 0;

  List<int?> times = [null, 15, 30, 45, 60];

  void updateText(int index) {
    final time = times[index];

    setState(() {
      text = time == null ? "OFF" : "$time mins";
      selectedIndex = index;
    });
    widget.onUpdate(time);
  }

  @override
  Widget build(BuildContext context) {
    return QuizSetupWidget(
      leading: "QUIZ DURATION",
      trailing: text ?? "OFF",
      child: Stack(
        alignment: Alignment.center,
        children: [
          Divider(
            endIndent: 30,
            indent: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(times.length, (index) {
              return DurationWidget(
                times[index],
                onTap: () => updateText(index),
                selected: selectedIndex == index,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class DurationWidget extends StatelessWidget {
  final VoidCallback onTap;
  final int? time;
  final bool selected;

  const DurationWidget(
    this.time, {
    super.key,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(360),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : CupertinoColors.secondarySystemBackground,
          shape: BoxShape.circle,
          border: Border.all(
              color: selected ? AppColors.primary : CupertinoColors.systemGrey),
        ),
        child: Text(
          time == null ? "OFF" : "$time",
          style: TextStyle(
              fontFamily: "Proxima Nova",
              fontSize: 14,
              color: selected
                  ? CupertinoColors.secondarySystemBackground
                  : CupertinoColors.systemGrey,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
