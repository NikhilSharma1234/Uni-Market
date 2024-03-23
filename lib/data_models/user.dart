
// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class UniMarketUser {
  String? assignable_profile_pic;
  Timestamp? createdAt;
  bool? darkMode;
  Timestamp? deletedAt;
  String? email;
  bool? emailVerified;
  String? marketplaceId;
  String? name;
  String? schoolId;
  String? starting_profile_pic;
  Timestamp? updatedAt;
  bool? verificationDocsUploaded;
  bool? verifiedUniStudent;
  String? verifiedBy;
  Timestamp? verifiedAt;
  List? verificationDocs;

  delete() {
    assignable_profile_pic = null;
    createdAt = null;
    darkMode = null;
    deletedAt = null;
    email = null;
    emailVerified = null;
    marketplaceId = null;
    name = null;
    schoolId = null;
    starting_profile_pic = null;
    updatedAt = null;
    verificationDocsUploaded = null;
    verifiedUniStudent = null;
    verifiedBy = null;
    verifiedAt = null;
    verificationDocs = null;
  }

  UniMarketUser({
    required this.assignable_profile_pic,
    required this.createdAt,
    required this.darkMode,
    required this.deletedAt,
    required this.email,
    required this.emailVerified,
    required this.marketplaceId,
    required this.name,
    required this.schoolId,
    required this.starting_profile_pic,
    required this.updatedAt,
    required this.verificationDocsUploaded,
    required this.verifiedUniStudent,
    required this.verifiedBy,
    required this.verifiedAt,
    this.verificationDocs,
  });
}