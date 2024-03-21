// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uni_market/data_models/current_user.dart';
import 'package:uni_market/data_store.dart' as data_store;

Future<void> loadCurrentUser(email) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var tempUserSnapshot = await firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
  var userData = tempUserSnapshot.docs[0].data();
  // Non DB defined fields
  String? assignable_profile_pic_url;
  String starting_profile_pic_url;
  String institutionFullName = "";
  List<dynamic> schoolsInMarketplace = [];

  // Get assignable profile pic URL
  if (userData["assignable_profile_pic_path"] != null) {
    assignable_profile_pic_url = await FirebaseStorage.instance
      .ref()
      .child(userData["assignable_profile_pic"])
      .getDownloadURL();
  }

  // Get starting profile pic url
  starting_profile_pic_url = await FirebaseStorage.instance
    .ref()
    .child(userData["starting_profile_pic"])
    .getDownloadURL();

  // Read schools in users marketplace Id from db
  await FirebaseFirestore.instance
      .collection("marketplace")
      .doc(userData["marketplaceId"])
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    schoolsInMarketplace = documentSnapshot.get("schoolIds");
  });
  // read school fullname
  await FirebaseFirestore.instance
      .collection("schools")
      .doc(userData["schoolId"])
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    institutionFullName = documentSnapshot.get("name");
  });
  data_store.user = CurrentUser(
    assignable_profile_pic: userData['assignable_profile_pic'],
    assignable_profile_pic_url: assignable_profile_pic_url,
    createdAt: userData['createdAt'],
    darkMode: userData['darkMode'],
    deletedAt : userData['deletedAt'],
    email : userData['email'],
    emailVerified : userData['emailVerified'],
    institutionFullName : institutionFullName,
    marketplaceId : userData['marketplaceId'],
    name : userData['name'],
    schoolId : userData['schoolId'],
    schoolsInMarketplace: schoolsInMarketplace,
    starting_profile_pic : userData['starting_profile_pic'],
    starting_profile_pic_url: starting_profile_pic_url,
    updatedAt : userData['updatedAt'],
    verificationDocsUploaded : userData['verificationDocsUploaded'],
    verifiedUniStudent : userData['verifiedUniStudent'],
    verifiedBy: userData['verifiedBy'],
    verifiedAt: userData['verifiedAt']
  );
}