import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:retrofit/retrofit.dart';

import '../model/response_model.dart';
import 'data_state.dart';

Future<DataState<T>> performRequest<T>(Future<HttpResponse<T>> request) async {
  try {
    final httpResponse = await request;
    if ([HttpStatus.ok, HttpStatus.created]
        .contains(httpResponse.response.statusCode)) {
      return DataSuccess(httpResponse.data);
    } else {
      final jsonData = jsonDecode(httpResponse.response.toString());
      final responseModel =
          ResponseModel.fromJson(jsonData, (json) => json as dynamic);
      String errorMessage = responseModel.message ??
          _handleBadResponse(httpResponse.response.statusCode);
      print(errorMessage);
      return DataException(
        DioException(
          error: httpResponse.response.statusMessage,
          response: httpResponse.response,
          type: DioExceptionType.badResponse,
          requestOptions: httpResponse.response.requestOptions,
          message: errorMessage,
        ),
      );
    }
  } on DioException catch (e) {
    debugPrint(e.toString());
    String errorMessage;
    print(e);
    try {
      final responseModel = ResponseModel.fromJson(
          jsonDecode(e.response.toString()), (json) => json as dynamic);
      errorMessage = responseModel.message ?? _handleDioError(e);
      debugPrint('Error message from response: ${responseModel.message}');

      // Global.showErrorMessage(message: errorMessage);
    } catch (error) {
      // Global.showErrorMessage(
      //     message: "An internal error occurred, Try again later!");
      errorMessage = _handleDioError(e);
    }
    return DataException(
      DioException(
        requestOptions: e.requestOptions,
        error: e.error,
        type: e.type,
        response: e.response,
        message: errorMessage,
      ),
    );
  }
}

String _handleBadResponse(int? statusCode) {
  switch (statusCode) {
    case 400:
      return 'Bad request';
    case 401:
      return 'Unauthorized';
    case 403:
      return 'Forbidden';
    case 404:
      return 'Not found';
    case 500:
      return 'Internal server error';
    default:
      return 'An error occurred';
  }
}

String _handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Connection timed out. Please check your internet connection.';
    case DioExceptionType.badResponse:
      return _handleBadResponse(error.response?.statusCode);
    case DioExceptionType.cancel:
      return 'Request cancelled. Please try again.';
    case DioExceptionType.unknown:
      if (error.error != null &&
          error.error.toString().contains('SocketException')) {
        return 'No internet connection. Please check your network.';
      }
      return 'An unexpected error occurred. Please try again.';
    default:
      return 'An error occurred. Please try again.';
  }
}
