export 'firebase_upload_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_market/services/upload_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      return null;
    }
  }

  @override
  Future<String?> uploadFileFromBytes(
      Uint8List fileBytes, String fileName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.email;
      var fileRef = FirebaseStorage.instance
          .ref()
          .child('verification/$userId/$fileName');
      var uploadTask = await fileRef.putData(fileBytes);
      await uploadTask.ref.getDownloadURL();
      return fileName;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      return null;
    }
  }

  Future<void> uploadSelectedSchool(String schoolName) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      //   'school': schoolName,
      // }, SetOptions(merge: true));
      if (kDebugMode) {
        print(schoolName);
      }
      // Optionally, handle successful upload
    } else {
      // Optionally, handle the case where there is no user logged in
    }
  }
}
