import 'package:flutter/cupertino.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_setup_widget.dart';

class QuizLengthWidget extends StatefulWidget {
  final Function(int questions) onUpdate;

  const QuizLengthWidget({super.key, required this.onUpdate});

  @override
  State<QuizLengthWidget> createState() => _QuizLengthWidgetState();
}

class _QuizLengthWidgetState extends State<QuizLengthWidget> {
  double length = 10;

  @override
  Widget build(BuildContext context) {
    return QuizSetupWidget(
      leading: "QUIZ LENGTH",
      trailing: "${length.toInt()} Questions",
      child: SizedBox(
        width: double.infinity,
        child: CupertinoSlider(
            value: length,
            max: 50,
            divisions: 9,
            min: 5,
            onChanged: (value) {
              widget.onUpdate(value.toInt());
              setState(() {
                length = value;
              });
            }),
      ),
    );
  }
}
