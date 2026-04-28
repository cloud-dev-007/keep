import 'package:qcraft/core/model/document_model.dart';

abstract class UploadState {
  final List<DocumentModel>? documents;

  const UploadState({
    this.documents,
  });
}

class RetrievedUploadedDocument extends UploadState {
  const RetrievedUploadedDocument(
    List<DocumentModel> docs,
  ) : super(documents: docs);
}

class SelectedDocumentState extends UploadState {
  final num id;

  const SelectedDocumentState(this.id);
}

class UploadInitial extends UploadState {
  UploadInitial();
}

class UploadLoading extends UploadState {
  UploadLoading();
}

class UploadException extends UploadState {
  UploadException();
}

class UploadSuccess extends UploadState {
  UploadSuccess();
}
