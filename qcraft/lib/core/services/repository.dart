import 'package:dio/dio.dart';
import 'package:qcraft/core/model/document_model.dart';
import 'package:qcraft/core/model/quiz_attempt_model.dart';
import 'package:qcraft/core/model/quiz_model.dart';
import 'package:qcraft/core/model/quiz_setup_model.dart';
import 'package:qcraft/core/services/api_service.dart';

import '../model/response_model.dart';
import '../resources/data_state.dart';
import '../resources/perform_request.dart';

class Repository {
  final ApiService _apiService;

  Repository(this._apiService);

  // region Documents
  Future<DataState<ResponseModel<List<DocumentModel>>>> getDocuments(
      List<num>? documentIds) {
    return performRequest(_apiService.getDocuments(documentIds: documentIds));
  }

  Future<DataState<ResponseModel>> deleteDocument(num id) {
    return performRequest(_apiService.deleteDocument(id));
  }

  Future<DataState<ResponseModel>> uploadDocument(List<MultipartFile> files) {
    return performRequest(_apiService.uploadDocument(
      files: files,
      contentType: "multipart/form-data",
    ));
  }

  // endregion

  // region Quiz

  Future<DataState<ResponseModel<List<QuizModel>>>> getQuizzes(
      {List<num>? ids}) {
    return performRequest(_apiService.getQuizzes(quizIds: ids));
  }

  Future<DataState<ResponseModel<num>>> createQuiz(QuizSetupModel setup) {
    return performRequest(_apiService.createQuiz(setup));
  }

  Future<DataState<ResponseModel<QuizAttemptModel>>> evaluateQuiz(
      QuizAttemptModel attempt) {
    return performRequest(_apiService.evaluateQuiz(attempt));
  }

  Future<DataState<ResponseModel<QuizModel>>> generateQuiz(num id,
      {QuizAttemptModel? attempt}) {
    return performRequest(_apiService.generateQuiz(id, attempt: attempt));
  }
//endregion
}
