export 'firebase_upload_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_market/services/upload_services.dart';

class FirebaseUploadService extends UploadService {
  @override
  Future<String?> uploadFile(Object file, String fileName) async {
    if (file is! File) {
      throw 'File type not supported';
    }

    try {
      final userId = FirebaseAuth.instance.currentUser!.email;
      var fileRef = FirebaseStorage.instance
          .ref()
          .child('verification/$userId/$fileName');
      var uploadTask = fileRef.putFile(file);
      var downloadUrl = await (await uploadTask).ref.getDownloadURL();
      return downloadUrl.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      return null;
    }
  }

  Future<String?> uploadImage(XFile file, String fileName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.email;
      Future<String?> imageDataUrl = convertImageToDataUrl(file);
      String? dataUrl = await imageDataUrl;
      Uint8List imageBytes = base64Decode(dataUrl!.split(',').last);
      var fileRef = FirebaseStorage.instance
          .ref()
          .child('verification/$userId/$fileName');
      await fileRef.putData(imageBytes);
      return fileName;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      return null;
    }
  }

  Future<String?> convertImageToDataUrl(XFile? imageFile) async {
    if (imageFile != null) {
      List<int> imageBytes = await imageFile.readAsBytes();
      String? dataUrl =
          'data:image/${imageFile.name.split('.').last};base64,${base64Encode(Uint8List.fromList(imageBytes))}';
      return dataUrl;
    }
    return null;
  }

  @override
  Future<String?> uploadFileFromBytes(
      Uint8List fileBytes, String fileName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.email;
      var fileRef = FirebaseStorage.instance
          .ref()
          .child('verification/$userId/$fileName');
      await fileRef.putData(fileBytes);
      return fileName;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      return null;
    }
  }
}
