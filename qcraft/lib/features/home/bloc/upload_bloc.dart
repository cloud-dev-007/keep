import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/core/services/file_upload_service.dart';
import 'package:qcraft/core/services/repository.dart';
import 'package:qcraft/features/home/bloc/upload_event.dart';
import 'package:qcraft/features/home/bloc/upload_state.dart';

import '../../../core/resources/data_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final FileUploadService _fileUploadService;
  final Repository _repository;

  UploadBloc(this._fileUploadService, this._repository)
      : super(UploadInitial()) {
    on<GetUploadedDocumentsEvent>(onGetUploadedDocuments);
    on<UploadDocumentEvent>(onUploadDocument);
    on<SelectDocumentEvent>(onSelectDocument);
    on<DeleteDocumentEvent>(onDeleteDocument);
  }

  void onGetUploadedDocuments(
      GetUploadedDocumentsEvent event, Emitter<UploadState> emit) async {
    emit(UploadLoading());
    final dataState = await _repository.getDocuments(event.documentIds);

    if (dataState is DataSuccess) {
      print("Document Retrieval Successful");
      emit(RetrievedUploadedDocument(dataState.data!.data!));
    } else {
      print("Upload Failed: ${dataState.exception}");
      emit(UploadException());
    }
  }

  void onUploadDocument(
      UploadDocumentEvent event, Emitter<UploadState> emit) async {
    emit(UploadLoading());

    List<File> files = await _fileUploadService.pickMultipleFiles(
        allowedExtensions: event.allowedExtensions);
    List<MultipartFile> multipartFiles =
        await _fileUploadService.prepareFilesForUpload(files);
    final dataState = await _repository.uploadDocument(multipartFiles);

    if (dataState is DataSuccess) {
      print("Upload Successful");
      emit(UploadSuccess());
      add(GetUploadedDocumentsEvent());
    } else {
      print("Upload Failed: ${dataState.exception}");
      emit(UploadException());
    }
  }

  void onDeleteDocument(
      DeleteDocumentEvent event, Emitter<UploadState> emit) async {
    emit(UploadLoading());

    _repository.deleteDocument(event.id);

    emit(UploadSuccess());
  }

  void onSelectDocument(
      SelectDocumentEvent event, Emitter<UploadState> emit) async {
    emit(SelectedDocumentState(event.id));
  }
}
