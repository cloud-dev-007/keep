abstract class UploadEvent {
  const UploadEvent();
}

class GetUploadedDocumentsEvent extends UploadEvent {
  final List<num>? documentIds;

  const GetUploadedDocumentsEvent({this.documentIds = const []});
}

class SelectDocumentEvent extends UploadEvent {
  final num id;

  const SelectDocumentEvent(this.id);
}

class UploadDocumentEvent extends UploadEvent {
  final List<String>? allowedExtensions;

  const UploadDocumentEvent(
      {this.allowedExtensions = const ["pdf", "docx", "doc", "pptx", "epub"]});
}

class DeleteDocumentEvent extends UploadEvent {
  final num id;

  const DeleteDocumentEvent({required this.id});
}
