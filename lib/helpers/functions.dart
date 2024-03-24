// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/data_models/current_user.dart';
import 'package:uni_market/data_store.dart' as data_store;
import 'package:uni_market/helpers/filters.dart';
import 'package:http/http.dart' as http;
import 'package:uni_market/components/ItemGeneration/abstract_item_factory.dart';

final Map<String, String> headers = {
  "Access-Control-Allow-Origin": "*",
  'Access-Control-Allow-Methods': 'true',
  "X-TYPESENSE-API-KEY": 'eSMjP8YVxHdMKoT164TTKLMkXRS47FdDnPENNAA2Ob8RfEfr',
}; // TODO: generate search api keys for each collection (waiting until formats are finalized so keys dont get nuked)

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
  if (userData["assignable_profile_pic"] != null) {
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

searchSuggestions(String searchTerm, int number) async {
  List<String> suggestions = [];

  String url = "https://hawk-perfect-frog.ngrok-free.app";

  Uri searchUrl = Uri.parse(
      "$url/collections/suggestions/documents/search?q=$searchTerm&query_by=embedding,suggestion&per_page=$number");

  Map<String, dynamic> data = {};

  try {
    // search typesense
    final response = await http.get(searchUrl, headers: headers);

    if (response.statusCode == 200) {
      // Decode the JSON response
      data = json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Handle error
      throw Exception('Failed to fetch items: ${response.statusCode}');
    }
  } catch (e) {
    // error snackbar
  }

  for (var item in data['hits']) {
    suggestions.add(item['document']['suggestion']);
  }
  return suggestions;
}

searchTags(String searchTerm, int number, List<String?> currentTags) async {
  List<String> tags = [];

  String url = "https://hawk-perfect-frog.ngrok-free.app";
  String items = "";
  if (currentTags.isNotEmpty) {
    items = "tag:!=[";
    for (var tag in currentTags) {
      items += "${tag!},";
    }
    items = "${items.substring(0, items.length - 1)}]";
  } else {
    items = "";
  }

  Uri searchUrl = Uri.parse(
      "$url/collections/tags/documents/search?q=$searchTerm&query_by=embedding,tag&per_page=$number&filter_by=$items");

  Map<String, dynamic> data = {};

  try {
    // search typesense
    final response = await http.get(searchUrl, headers: headers);

    if (response.statusCode == 200) {
      // Decode the JSON response
      data = json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Handle error
      throw Exception('Failed to fetch items: ${response.statusCode}');
    }
  } catch (e) {
    // error snackbar
  }

  for (var item in data['hits']) {
    tags.add(item['document']['tag']);
  }
  return tags;
}

search(
    String searchTerm, int number, BuildContext context, Filters filter) async {
  List<Widget> widgets = [];

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

  filterString +=
      "&&sellerId:!=${data_store.user.email}&&isFlagged:=false&&deletedAt:=None&&marketplaceId:=${data_store.user.marketplaceId}";

  final searchParameters = [
    searchTerm,
    "embedding,name,description,tags",
    sort,
    filterString,
    30
  ];

  String url = "https://hawk-perfect-frog.ngrok-free.app";

  Uri searchUrl = Uri.parse(
      "$url/collections/items/documents/search?q=${searchParameters[0]}&query_by=${searchParameters[1]}&sort_by=${searchParameters[2]}&filter_by=${searchParameters[3]}&per_page=${searchParameters[4]}");
  Map<String, dynamic> data = {};

  try {
    // search typesense
    final response = await http.get(searchUrl, headers: headers);

    if (response.statusCode == 200) {
      // Decode the JSON response
      data = json.decode(response.body) as Map<String, dynamic>;
    } else {
      // Handle error
      throw Exception('Failed to fetch items: ${response.statusCode}');
    }
  } catch (e) {
    // error snackbar
  }

  if (context.mounted) {
    widgets = await generateItems(data, context);
  } else {
    if (kDebugMode) {
      print("no clue as to whats going on, buildcontext wasnt mounded");
    }
  }

  data_store.itemBoxes = widgets;

  return widgets;
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
