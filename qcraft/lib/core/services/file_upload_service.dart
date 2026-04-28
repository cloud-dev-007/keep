import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class FileUploadService {
  /// Pick a single file
  Future<File?> pickSingleFile({List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// Pick multiple files
  Future<List<File>> pickMultipleFiles(
      {List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );

    if (result != null) {
      return result.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();
    }
    return [];
  }

  /// Prepare a single file for Dio upload
  Future<MultipartFile> prepareFileForUpload(File file) async {
    final fileName = file.path
        .split('/')
        .last;
    return await MultipartFile.fromFile(file.path, filename: fileName);
  }

  /// Prepare multiple files for Dio upload
  Future<List<MultipartFile>> prepareFilesForUpload(List<File> files) async {
    return Future.wait(files.map((file) => prepareFileForUpload(file)));
  }
}
