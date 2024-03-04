import 'dart:typed_data';

abstract class UploadService {
  Future<String?> uploadFile(Object file, String fileName);
  Future<String?> uploadFileFromBytes(Uint8List fileBytes, String fileName);
}
