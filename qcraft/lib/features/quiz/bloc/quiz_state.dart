import 'package:qcraft/core/model/quiz_attempt_model.dart';
import 'package:qcraft/core/model/quiz_model.dart';

class QuizState {
  final List<QuizModel>? quizzes;

  const QuizState({this.quizzes});
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class RetrievedQuizzes extends QuizState {
  const RetrievedQuizzes(
    List<QuizModel> quizzes,
  ) : super(quizzes: quizzes);
}

class QuizPageChanged extends QuizState {
  final int index;

  const QuizPageChanged(this.index);
}

class QuizGenerated extends QuizState {
  final QuizModel quiz;

  const QuizGenerated(this.quiz);
}

class QuizEvaluated extends QuizState {
  final QuizAttemptModel attempt;

  const QuizEvaluated(this.attempt);
}

class QuizPaused extends QuizState {
  final bool isPaused;

  const QuizPaused(this.isPaused);
}

class QuizCreated extends QuizState {
  final num id;

  const QuizCreated(this.id);
}

class QuizException extends QuizState {}
