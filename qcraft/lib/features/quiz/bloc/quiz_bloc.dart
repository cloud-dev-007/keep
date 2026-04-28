import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/features/quiz/bloc/quiz_event.dart';
import 'package:qcraft/features/quiz/bloc/quiz_state.dart';

import '../../../core/resources/data_state.dart';
import '../../../core/services/repository.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final Repository _repository;

  QuizBloc(this._repository) : super(QuizInitial()) {
    on<CreateQuiz>(onCreateQuiz);
    on<GenerateQuiz>(onGenerateQuiz);
    on<EvaluateQuiz>(onEvaluateQuiz);
    on<ToggleTimer>(onToggleTimer);
    on<GetQuizzes>(onGetQuizzes);
    on<ChangePageIndex>(onChangePageIndex);
  }

  Future<void> onGetQuizzes(GetQuizzes event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    final dataState = await _repository.getQuizzes();

    if (dataState is DataSuccess) {
      print("Quiz Retrieved Successful");
      emit(RetrievedQuizzes(dataState.data!.data!));
    } else {
      print("Quiz Retrieval Failed: ${dataState.exception}");
      emit(QuizException());
    }
  }

  Future<void> onChangePageIndex(
      ChangePageIndex event, Emitter<QuizState> emit) async {
    emit(QuizPageChanged(event.index));
  }

  Future<void> onCreateQuiz(CreateQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    print(event.setupModel.toJson());
    final dataState = await _repository.createQuiz(event.setupModel);

    if (dataState is DataSuccess) {
      print("Quiz Created Successful ${dataState.data!.data!}");
      emit(QuizCreated(dataState.data!.data!));
    } else {
      print("Quiz Creation Failed: ${dataState.exception}");
      emit(QuizException());
    }
  }

  Future<void> onToggleTimer(ToggleTimer event, Emitter<QuizState> emit) async {
    emit(QuizPaused(event.isPaused));
  }

  Future<void> onGenerateQuiz(
      GenerateQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    final dataState =
        await _repository.generateQuiz(event.quizId, attempt: event.attempt);

    if (dataState is DataSuccess) {
      print("Quiz Generating");
      emit(QuizGenerated(dataState.data!.data!));
    } else {
      print("Quiz Generation Failed: ${dataState.exception}");
      emit(QuizException());
    }
  }

  Future<void> onEvaluateQuiz(
      EvaluateQuiz event, Emitter<QuizState> emit) async {
    emit(QuizLoading());
    final dataState = await _repository.evaluateQuiz(event.attempt);

    if (dataState is DataSuccess) {
      print("Quiz Evaluating");

      print(dataState.data!.data!.toJson());
      emit(QuizEvaluated(dataState.data!.data!));
    } else {
      print("Quiz Evaluation Failed: ${dataState.exception}");
      emit(QuizException());
    }
  }
}
