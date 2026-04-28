import 'package:qcraft/core/model/quiz_attempt_model.dart';
import 'package:qcraft/core/model/quiz_setup_model.dart';

class QuizEvent {
  const QuizEvent();
}

class GetQuizzes extends QuizEvent {
  const GetQuizzes();
}

class ChangePageIndex extends QuizEvent {
  final int index;

  const ChangePageIndex(this.index);
}

class CreateQuiz extends QuizEvent {
  final QuizSetupModel setupModel;

  const CreateQuiz({required this.setupModel});
}

class EvaluateQuiz extends QuizEvent {
  final QuizAttemptModel attempt;

  const EvaluateQuiz(this.attempt);
}

class GenerateQuiz extends QuizEvent {
  final num quizId;
  final QuizAttemptModel? attempt;

  const GenerateQuiz(this.quizId, {this.attempt});
}

class ToggleTimer extends QuizEvent {
  final bool isPaused;

  const ToggleTimer(this.isPaused);
}
