// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:typesense/typesense.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/data_models/current_user.dart';
import 'package:uni_market/data_store.dart' as data_store;
import 'package:uni_market/helpers/filters.dart';
import 'package:uni_market/components/ItemGeneration/abstract_item_factory.dart';

Future<void> loadCurrentUser(email) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var tempUserSnapshot = await firestore
      .collection('users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();
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
      deletedAt: userData['deletedAt'],
      email: userData['email'],
      emailVerified: userData['emailVerified'],
      institutionFullName: institutionFullName,
      marketplaceId: userData['marketplaceId'],
      name: userData['name'],
      schoolId: userData['schoolId'],
      schoolsInMarketplace: schoolsInMarketplace,
      starting_profile_pic: userData['starting_profile_pic'],
      starting_profile_pic_url: starting_profile_pic_url,
      updatedAt: userData['updatedAt'],
      verificationDocsUploaded: userData['verificationDocsUploaded'],
      verifiedUniStudent: userData['verifiedUniStudent'],
      verifiedBy: userData['verifiedBy'],
      verifiedAt: userData['verifiedAt']);
}

search(
    String searchTerm, int number, BuildContext context, Filters filter) async {
  List<Widget> widgets = [];
  final config = Configuration(
    'eSMjP8YVxHdMKoT164TTKLMkXRS47FdDnPENNAA2Ob8RfEfr',
    nodes: {
      Node(
        Protocol.https,
        "hawk-perfect-frog.ngrok-free.app",
        port: 443, // stuff provided by the cloud hosting
      ),
    },
    // numRetries: 3, // A total of 4 tries (1 original try + 3 retries)
    connectionTimeout: const Duration(seconds: 2),
  );

  final client = Client(config);

  String filterString = 'price:[${filter.lowerPrice}..${filter.upperPrice}]';

  String sort = '';

  switch (filter.sort) {
    case Sort.newestToOldest:
      sort = 'dateListed:desc';
      break;
    case Sort.oldestToNewest:
      sort = 'dateListed:asc';
      break;
    case Sort.highToLow:
      sort = 'price:desc';
      break;
    case Sort.lowToHigh:
      sort = 'price:asc';
      break;
    default:
      break;
  }

  switch (filter.condition) {
    case Condition.newItem:
      filterString += ' && condition:NEW';
      break;
    case Condition.usedItem:
      filterString += ' && condition:USED';
      break;
    case Condition.wornItem:
      filterString += ' && condition:WORN';
      break;
    case Condition.none:
      break;
  }

  final searchParameters = {
    'q': searchTerm,
    'query_by': 'embedding',
    'sort_by': sort,
    'filter_by': filterString,
  };
  final Map<String, dynamic> data =
      await client.collection('items').documents.search(searchParameters);
  if (context.mounted) {
    widgets = await generateItems(data, context);
  } else {
    if (kDebugMode) {
      print("no clue as to whats going on, buildcontext wasnt mounded");
    }
  }
  data_store.itemBoxes = widgets;
}

generateItems(Map<String, dynamic> data, BuildContext context) async {
  AbstractItemFactory factory = AbstractItemFactory();
  List<Widget> widgets = [];
  for (var item in data['hits']) {
    if (item['document']['images'].length == 0) {
      item['document']['images'].add(await FirebaseStorage.instance
          .ref("images/missing_image.jpg")
          .getDownloadURL());
    } else {
      for (int i = 0; i < item['document']['images'].length; i++) {
        item['document']['images'][i] =
            await getURL(item['document']['images'][i]);
      }
    }

    if (context.mounted) {
      widgets.add(factory.buildItemBox(
          Item.fromJSON(item['document']), context)); // this is the issue
    }
  }
  return widgets;
}

Future<String> getURL(
  String imageURL,
) async {
  String image;
  try {
    image = await FirebaseStorage.instance.ref(imageURL).getDownloadURL();
  } catch (e) {
    image = "Missing Image";
  }
  return image;
}
