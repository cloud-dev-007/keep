import 'package:flutter/foundation.dart';

import '../api/models.dart';

/// In-flight state for one quiz attempt. Owns the user's answer per question
/// and tracks elapsed time. Pass the same instance from TakeQuiz to Result.
class QuizSession extends ChangeNotifier {
  QuizSession({required this.quiz}) : startedAt = DateTime.now();

  final QuizModel quiz;
  final DateTime startedAt;

  /// questionId -> answer text. For MCQ this is the chosen option's value;
  /// for TrueFalse it's 'true' or 'false'; for Theory/FITB it's the raw text.
  final Map<int, String> _answers = <int, String>{};

  int _index = 0;
  int get index => _index;

  int get total => quiz.questions.length;

  QuizQuestionModel get current => quiz.questions[_index];

  bool get isLast => _index >= total - 1;
  bool get isFirst => _index == 0;

  String? answerFor(int questionId) => _answers[questionId];

  void setAnswer(int questionId, String value) {
    _answers[questionId] = value;
    notifyListeners();
  }

  void next() {
    if (_index < total - 1) {
      _index++;
      notifyListeners();
    }
  }

  void previous() {
    if (_index > 0) {
      _index--;
      notifyListeners();
    }
  }

  int get answeredCount => _answers.values.where((v) => v.trim().isNotEmpty).length;

  Duration get elapsed => DateTime.now().difference(startedAt);

  /// Build the body for POST /quiz/evaluate. Pre-computes correctness for the
  /// question types we can grade locally (MCQ, TrueFalse) so the LLM only has
  /// to judge Theory / FillInTheBlank — saves tokens.
  QuizAttemptRequest toRequest() {
    final attempts = <QuestionAttemptRequest>[];
    for (final q in quiz.questions) {
      final value = (_answers[q.id] ?? '').trim();
      final correct = _correctnessIfLocal(q, value);
      attempts.add(QuestionAttemptRequest(
        questionId: q.id,
        value: value,
        correct: correct,
      ));
    }
    return QuizAttemptRequest(
      quizId: quiz.id,
      attempts: attempts,
      difficulty: quiz.difficulty,
      timeTaken: elapsed.inSeconds,
    );
  }

  static bool? _correctnessIfLocal(QuizQuestionModel q, String userValue) {
    final t = q.type;
    if (t == 'MCQ' && q.options.isNotEmpty) {
      final picked = q.options.where((o) => o.value == userValue).toList();
      if (picked.isEmpty) return false;
      return picked.first.isAnswer;
    }
    if (t == 'TrueFalse') {
      final canon = userValue.trim().toLowerCase();
      final expected = (q.answer ?? '').trim().toLowerCase();
      if (expected.isEmpty) return null;
      return canon == expected;
    }
    return null; // Let the server / LLM judge.
  }
}
