library data_store;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uni_market/data_models/current_user.dart';

CurrentUser user = CurrentUser(
  assignable_profile_pic: null,
  createdAt: Timestamp.now(),
  darkMode: 0,
  deletedAt : null,
  email : "",
  emailVerified : false,
  marketplaceId : "",
  name : "",
  schoolId : "",
  starting_profile_pic : "",
  starting_profile_pic_url: "",
  updatedAt : Timestamp.now(),
  verificationDocsUploaded : false,
  verifiedUniStudent : false,
  verifiedBy: null,
  verifiedAt: null,
  institutionFullName: '',
  schoolsInMarketplace: [],
);