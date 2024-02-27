import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/ItemGeneration/AbstractItemFactory.dart';
import 'package:uni_market/components/ItemGeneration/ItemBox.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/components/navbar.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';

class ItemView extends StatefulWidget {
  final String? sellerID;

  const ItemView({
    Key? key,
    required this.sellerID,
  }) : super(key: key);

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  late List<Widget> items = [const Text("")];
  var db = FirebaseFirestore.instance;
  AbstractItemFactory factory = AbstractItemFactory();

  Future<String> getURL(String imageURL) async {
    String image;
    try {
      image = await FirebaseStorage.instance.ref(imageURL).getDownloadURL();
    } catch (e) {
      image = "Missing Image";
    }
    return image;
  }

  getItems() async {
    List<Widget> foundItemsArr = [];
    var foundItems = await db
        .collection("items")
        .where("sellerId", isEqualTo: widget.sellerID)
        .get();

    for (var docSnap in foundItems.docs) {
      var item = docSnap.data();
      if (item['images'].length == 0) {
        item['images'].add(await FirebaseStorage.instance
            .ref("images/missing_image.jpg")
            .getDownloadURL());
      } else {
        for (int i = 0; i < item['images'].length; i++) {
          item['images'][i] = await getURL(item['images'][i]);
        }
        if (context.mounted) {
          foundItemsArr
              .add(factory.buildItemBox(Item.fromFirebase(item), context));
        }
      }
    }
    return foundItemsArr;
  }

  @override
  void didChangeDependencies() {
    getItems().then((value) => setState((() {
          items = value;
        })));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (widget.sellerID == null) {
      items = [const Text("Issue getting user")];
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Items"),
        ),
        body: GridView.count(
          // truing to make scrolling smooth not working
          crossAxisCount: (screenWidth / 320).round(),
          childAspectRatio: 2 / 2,
          children: items,
        ));
  }
}
