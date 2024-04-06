import 'package:firebase_storage/firebase_storage.dart';



class ImageDataStore {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Map<String, String> _imageCache = {}; // Cache for image URLs
  

  ImageDataStore._privateConstructor();

  static final ImageDataStore _instance = ImageDataStore._privateConstructor();

  factory ImageDataStore() {
    return _instance;
  }

  Future<String?> getImageUrl(String imagePath) async {
  if (imagePath.isEmpty) {
    return null; // Return null if imagePath is empty
  } else if (_imageCache.containsKey(imagePath)) {
    return _imageCache[imagePath]!;
  } else {
    try {
      String imageUrl = await _storage.ref(imagePath).getDownloadURL();
      _imageCache[imagePath] = imageUrl;
      return imageUrl;
    } catch (e) {
      return null; // Return null in case of an error
    }
  }
}

}
