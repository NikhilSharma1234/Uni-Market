library data_store;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/data_models/current_user.dart';

CurrentUser user = CurrentUser(
    assignable_profile_pic: null,
    createdAt: Timestamp.now(),
    darkMode: 0,
    deletedAt: null,
    email: "",
    emailVerified: false,
    marketplaceId: "",
    name: "",
    schoolId: "",
    starting_profile_pic: "",
    starting_profile_pic_url: "",
    updatedAt: Timestamp.now(),
    verificationDocsUploaded: false,
    verifiedUniStudent: false,
    verifiedBy: null,
    verifiedAt: null,
    institutionFullName: '',
    schoolsInMarketplace: [],
    wishlist: []);

List<Widget> itemBoxes = [];

const missingImage =
    "https://firebasestorage.googleapis.com/v0/b/uni-market-1698103346694.appspot.com/o/images%2Fmissing_image.jpg?alt=media&token=a4a0c13e-5fb2-4ce8-be1e-5e3e7ee16cf3";
