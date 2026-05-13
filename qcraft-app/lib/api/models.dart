// ignore_for_file: avoid_dynamic_calls

/// Mirrors the QuizType enum in q-engine (src/quiz/enums/quiz-type.enum.ts).
/// The backend uses the string values — we send/parse them verbatim.
enum QuizType {
  mcq('MCQ', 'Multiple choice'),
  fillInTheBlank('FillInTheBlank', 'Fill in the blank'),
  trueFalse('TrueFalse', 'True / False'),
  theory('Theory', 'Theory / short answer'),
  any('Any', 'Mixed');

  const QuizType(this.wire, this.label);

  /// The exact string the backend expects/returns.
  final String wire;

  /// Human-readable label for UI.
  final String label;

  static QuizType fromWire(String? value) {
    if (value == null) return QuizType.any;
    for (final t in QuizType.values) {
      if (t.wire == value) return t;
    }
    return QuizType.any;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

List<String> _stringList(dynamic v) {
  if (v is List) return v.map((e) => e.toString()).toList(growable: false);
  return const <String>[];
}

int _asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

double? _asDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

// ---------------------------------------------------------------------------
// DocumentModel — mirrors Document entity (src/document/entity/document.entity.ts).
// ---------------------------------------------------------------------------

class DocumentModel {
  DocumentModel({
    required this.id,
    this.title,
    this.description,
    this.topics = const [],
    required this.formatType,
    required this.fileName,
    this.pageCount,
    this.createdAt,
  });

  final int id;
  final String? title;
  final String? description;
  final List<String> topics;
  final String formatType;
  final String fileName;
  final int? pageCount;
  final DateTime? createdAt;

  String get displayName {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    return fileName;
  }

  factory DocumentModel.fromJson(Map<String, dynamic> j) => DocumentModel(
        id: _asInt(j['id']),
        title: j['title'] as String?,
        description: j['description'] as String?,
        topics: _stringList(j['topics']),
        formatType: (j['formatType'] ?? '') as String,
        fileName: (j['fileName'] ?? j['filename'] ?? '') as String,
        pageCount: j['pageCount'] is num ? (j['pageCount'] as num).toInt() : null,
        createdAt: _parseDate(j['createdAt']),
      );
}

// ---------------------------------------------------------------------------
// Quiz / Question / Option / Attempt models.
// ---------------------------------------------------------------------------

class QuizOptionModel {
  QuizOptionModel({required this.id, required this.value, required this.isAnswer});

  final int id;
  final String value;
  final bool isAnswer;

  factory QuizOptionModel.fromJson(Map<String, dynamic> j) => QuizOptionModel(
        id: _asInt(j['id']),
        value: (j['value'] ?? '') as String,
        isAnswer: j['isAnswer'] == true,
      );
}

class QuizQuestionModel {
  QuizQuestionModel({
    required this.id,
    required this.type,
    required this.question,
    this.answer,
    this.options = const [],
  });

  final int id;
  final String type;
  final String question;
  final String? answer;
  final List<QuizOptionModel> options;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> j) => QuizQuestionModel(
        id: _asInt(j['id']),
        type: (j['type'] ?? '') as String,
        question: (j['question'] ?? '') as String,
        answer: j['answer'] as String?,
        options: (j['options'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(QuizOptionModel.fromJson)
            .toList(growable: false),
      );
}

class QuizModel {
  QuizModel({
    required this.id,
    this.title,
    required this.difficulty,
    this.duration,
    required this.noOfQuestions,
    this.isAdaptive,
    required this.type,
    this.questions = const [],
    this.documents = const [],
    this.createdAt,
  });

  final int id;
  final String? title;
  final int difficulty;
  final int? duration;
  final int noOfQuestions;
  final bool? isAdaptive;
  final QuizType type;
  final List<QuizQuestionModel> questions;
  final List<DocumentModel> documents;
  final DateTime? createdAt;

  bool get hasQuestions => questions.isNotEmpty;

  String get displayTitle {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    return 'Quiz #$id';
  }

  factory QuizModel.fromJson(Map<String, dynamic> j) => QuizModel(
        id: _asInt(j['id']),
        title: j['title'] as String?,
        difficulty: _asInt(j['difficulty'], 1),
        duration: j['duration'] is num ? (j['duration'] as num).toInt() : null,
        noOfQuestions: _asInt(j['noOfQuestions']),
        isAdaptive: j['isAdaptive'] as bool?,
        type: QuizType.fromWire(j['type'] as String?),
        questions: (j['questions'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(QuizQuestionModel.fromJson)
            .toList(growable: false),
        documents: (j['documents'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(DocumentModel.fromJson)
            .toList(growable: false),
        createdAt: _parseDate(j['createdAt']),
      );
}

class QuestionAttemptResultModel {
  QuestionAttemptResultModel({
    required this.id,
    required this.value,
    required this.correct,
    this.questionId,
  });

  final int id;
  final String value;
  final bool correct;
  final int? questionId;

  factory QuestionAttemptResultModel.fromJson(Map<String, dynamic> j) {
    final question = j['question'];
    int? qid;
    if (question is Map<String, dynamic>) {
      qid = _asInt(question['id'], -1);
      if (qid == -1) qid = null;
    }
    return QuestionAttemptResultModel(
      id: _asInt(j['id']),
      value: (j['value'] ?? '') as String,
      correct: j['correct'] == true,
      questionId: qid,
    );
  }
}

class QuizAttemptResultModel {
  QuizAttemptResultModel({
    required this.id,
    this.accuracy,
    this.timeTaken,
    this.weakTopics = const [],
    this.analysis,
    required this.difficulty,
    this.attempts = const [],
    this.createdAt,
  });

  final int id;
  final double? accuracy;
  final int? timeTaken;
  final List<String> weakTopics;
  final String? analysis;
  final int difficulty;
  final List<QuestionAttemptResultModel> attempts;
  final DateTime? createdAt;

  /// Accuracy is sometimes returned 0–1, sometimes 0–100. Normalise to 0–100.
  double get accuracyPct {
    final a = accuracy;
    if (a == null) return 0;
    return a <= 1.0 ? a * 100 : a;
  }

  factory QuizAttemptResultModel.fromJson(Map<String, dynamic> j) =>
      QuizAttemptResultModel(
        id: _asInt(j['id']),
        accuracy: _asDoubleOrNull(j['accuracy']),
        timeTaken: j['timeTaken'] is num ? (j['timeTaken'] as num).toInt() : null,
        weakTopics: _stringList(j['weakTopics']),
        analysis: j['analysis'] as String?,
        difficulty: _asInt(j['difficulty'], 1),
        attempts: (j['attempts'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(QuestionAttemptResultModel.fromJson)
            .toList(growable: false),
        createdAt: _parseDate(j['createdAt']),
      );
}

// ---------------------------------------------------------------------------
// Request DTOs — what we send to the backend.
// ---------------------------------------------------------------------------

class QuizSetupRequest {
  QuizSetupRequest({
    required this.documentIds,
    required this.questions,
    required this.difficulty,
    required this.type,
    this.duration,
  });

  final List<int> documentIds;
  final int questions;
  final int difficulty;
  final QuizType type;
  final int? duration;

  Map<String, dynamic> toJson() => {
        'documentIds': documentIds,
        'questions': questions,
        'difficulty': difficulty,
        'type': type.wire,
        if (duration != null) 'duration': duration,
      };
}

class QuestionAttemptRequest {
  QuestionAttemptRequest({required this.questionId, required this.value, this.correct});

  final int questionId;
  final String value;
  final bool? correct;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'value': value,
        if (correct != null) 'correct': correct,
      };
}

class QuizAttemptRequest {
  QuizAttemptRequest({
    required this.quizId,
    required this.attempts,
    required this.difficulty,
    this.accuracy,
    this.timeTaken,
  });

  final int quizId;
  final List<QuestionAttemptRequest> attempts;
  final int difficulty;
  final double? accuracy;
  final int? timeTaken;

  Map<String, dynamic> toJson() => {
        'quizId': quizId,
        'attempts': attempts.map((a) => a.toJson()).toList(),
        'difficulty': difficulty,
        if (accuracy != null) 'accuracy': accuracy,
        if (timeTaken != null) 'timeTaken': timeTaken,
      };
}
