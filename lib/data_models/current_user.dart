// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUser {
  static final CurrentUser _user = CurrentUser._internal();
  String? assignable_profile_pic;
  String? assignable_profile_pic_url;
  late Timestamp createdAt;
  late int darkMode;
  Timestamp? deletedAt;
  late String email;
  late bool emailVerified;
  late String marketplaceId;
  late String name;
  late String schoolId;
  late String starting_profile_pic;
  late String starting_profile_pic_url;
  late Timestamp updatedAt;
  late bool verificationDocsUploaded;
  late bool verifiedUniStudent;
  String? verifiedBy;
  Timestamp? verifiedAt;

  factory CurrentUser({
    required String? assignable_profile_pic,
    String? assignable_profile_pic_url,
    required Timestamp createdAt,
    required int darkMode,
    required Timestamp? deletedAt,
    required String email,
    required bool emailVerified,
    required String marketplaceId,
    required String name,
    required String schoolId,
    required String starting_profile_pic,
    required String starting_profile_pic_url,
    required Timestamp updatedAt,
    required bool verificationDocsUploaded,
    required bool verifiedUniStudent,
    required String? verifiedBy,
    required Timestamp? verifiedAt
  }) {
    _user.assignable_profile_pic = assignable_profile_pic;
    _user.assignable_profile_pic_url = assignable_profile_pic_url;
    _user.createdAt = createdAt;
    _user.darkMode = darkMode;
    _user.deletedAt =deletedAt;
    _user.email = email;
    _user.emailVerified = emailVerified;
    _user.marketplaceId = marketplaceId;
    _user.name = name;
    _user.schoolId = schoolId;
    _user.starting_profile_pic = starting_profile_pic;
    _user.starting_profile_pic_url = starting_profile_pic_url;
    _user.updatedAt = updatedAt;
    _user.verificationDocsUploaded = verificationDocsUploaded;
    _user.verifiedUniStudent = verifiedUniStudent;
    _user.verifiedBy = verifiedBy;
    _user.verifiedAt = verifiedAt;
    return _user;
  }

  delete() {
    _user.assignable_profile_pic = null;
    _user.createdAt = Timestamp.now();
    _user.darkMode = 0;
    _user.deletedAt = null;
    _user.email = "";
    _user.emailVerified = false;
    _user.marketplaceId = "";
    _user.name = "";
    _user.schoolId = "";
    _user.starting_profile_pic = "";
    _user.starting_profile_pic_url = "";
    _user.updatedAt  = Timestamp.now();
    _user.verificationDocsUploaded = false;
    _user.verifiedUniStudent = false;
    _user.verifiedBy = null;
    _user.verifiedAt = null;
  }

  CurrentUser._internal();
}