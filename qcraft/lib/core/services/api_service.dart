import 'package:dio/dio.dart';
import 'package:qcraft/core/model/document_model.dart';
import 'package:qcraft/core/model/quiz_attempt_model.dart';
import 'package:qcraft/core/model/quiz_model.dart';
import 'package:qcraft/core/model/quiz_setup_model.dart';
import 'package:retrofit/retrofit.dart';

import '../constants/api_endpoints.dart';
import '../model/response_model.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiEndpoints.baseApiUrl)
abstract class ApiService {
  factory ApiService(Dio dio) = _ApiService;

  // region Document
  @POST(ApiEndpoints.uploadDocument)
  @MultiPart()
  Future<HttpResponse<ResponseModel>> uploadDocument({
    @Part(name: 'files') required List<MultipartFile> files,
    @Header("Content-Type") required String contentType,
  });

  @GET(ApiEndpoints.document)
  Future<HttpResponse<ResponseModel<List<DocumentModel>>>> getDocuments(
      {@Query("ids") List<num>? documentIds});

  @DELETE(ApiEndpoints.document)
  Future<HttpResponse<ResponseModel>> deleteDocument(@Query("id") num id);

  //endregion

  // region Quiz
  @GET(ApiEndpoints.quiz)
  Future<HttpResponse<ResponseModel<List<QuizModel>>>> getQuizzes(
      {@Query("ids") List<num>? quizIds});

  @POST(ApiEndpoints.createQuiz)
  Future<HttpResponse<ResponseModel<num>>> createQuiz(
      @Body() QuizSetupModel setup);

  @POST(ApiEndpoints.evaluateQuiz)
  Future<HttpResponse<ResponseModel<QuizAttemptModel>>> evaluateQuiz(
      @Body() QuizAttemptModel attempt);

  @POST(ApiEndpoints.generateQuiz)
  Future<HttpResponse<ResponseModel<QuizModel>>> generateQuiz(@Path() num id,
      {@Body() QuizAttemptModel? attempt});
//endregion
}
