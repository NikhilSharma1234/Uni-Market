export 'upload_service.dart';

abstract class UploadService {
  Future<String?> uploadFile(Object file, String fileName); // Return the name of the file
}
