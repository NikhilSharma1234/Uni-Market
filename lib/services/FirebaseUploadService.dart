export 'FirebaseUploadService.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '/services/UploadService.dart';

class FirebaseUploadService extends UploadService {
  @override
  Future<String?> uploadFile(Object file, String fileName) async {
    if (file is! File) {
      throw 'File type not supported';
    }

    try {
      var fileRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
      var uploadTask = fileRef.putFile(file);
      var downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl.toString();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  @override
  Future<String?> uploadFileFromBytes(Uint8List fileBytes, String fileName) async {
    try {
      var fileRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
      var uploadTask = fileRef.putData(fileBytes);
      var downloadUrl = await (await uploadTask).ref.getDownloadURL();
      if (downloadUrl != null) {
        return fileName;
      }
      return "Could not upload file, please try again.";

    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
}