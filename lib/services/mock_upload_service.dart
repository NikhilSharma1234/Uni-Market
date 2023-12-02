import 'upload_service.dart';

class MockUploadService extends UploadService {
  @override
  Future<String?> uploadFile(Object file, String fileName) async {
    // Simulate a delay for the mock upload.
    await Future.delayed(const Duration(seconds: 1));

    // Return the file name.
    return fileName;
  }
}
