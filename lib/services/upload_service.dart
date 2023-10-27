export 'upload_service.dart';

abstract class UploadService {
  Future<String?> uploadFile(Object file, String fileName); // Return the name of the file
}
//implement uploadFile method in firebase. Parameters can be (object file, string fileName) if you need it for backend. Returning the file name to be displayed at the frontend. But, name of the file can directly extracted at the frontend
//Currently, mockupload instance is used. Change it with firebase instace or appropriate method.