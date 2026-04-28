import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_setup_widget.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/quiz_type.dart';

class QuizTypeWidget extends StatefulWidget {
  final Function(QuizType type) onUpdate;

  const QuizTypeWidget({super.key, required this.onUpdate});

  @override
  State<QuizTypeWidget> createState() => _QuizTypeWidgetState();
}

class _QuizTypeWidgetState extends State<QuizTypeWidget> {
  QuizType selectedType = QuizType.mcq;
  int selectedIndex = 0;

  void updateText(int index) {
    final type = QuizType.values[index];
    setState(() {
      selectedType = type;
      selectedIndex = index;
    });
    widget.onUpdate(type);
  }

  @override
  Widget build(BuildContext context) {
    return QuizSetupWidget(
      leading: "QUIZ TYPE",
      trailing: selectedType.name,
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 8.0,
          children: List.generate(
            QuizType.values.length,
            (index) {
              final type = QuizType.values[index];
              return QuizTypeChip(
                type,
                selected: selectedIndex == index,
                onTap: () {
                  updateText(index);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class QuizTypeChip extends StatelessWidget {
  final QuizType type;
  final bool selected;
  final VoidCallback onTap;

  const QuizTypeChip(this.type,
      {super.key, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: onTap,
      child: Chip(
        label: Text(
          type.name,
          style: TextStyle(
              fontFamily: "Proxima Nova",
              fontSize: 14,
              color: selected
                  ? CupertinoColors.secondarySystemBackground
                  : CupertinoColors.systemGrey,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: selected
            ? AppColors.primary
            : CupertinoColors.secondarySystemBackground,
      ),
    );
  }
}
