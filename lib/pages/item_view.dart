import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/ItemGeneration/abstract_item_factory.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';

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
  // todo later: Make this page more generalized for whatever needs of items displays.
  late List<Widget> items = [];
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
      item['id'] = docSnap.id; // adding id to data

      if (item['images'].length == 0) {
        item['images'].add(await FirebaseStorage.instance
            .ref("images/missing_image.jpg")
            .getDownloadURL());
      } else {
        for (int i = 0; i < item['images'].length; i++) {
          item['images'][i] = await getURL(item['images'][i]);
        }
      }
      if (context.mounted) {
        foundItemsArr
            .add(factory.buildItemBox(Item.fromFirebase(item), context));
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
    if (widget.sellerID == null) {
      items = [const Text("Issue getting user")];
    }

    Widget body;

    body = SingleChildScrollView(child: Wrap(children: items));

    if (items.isEmpty) {
      body = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Text('No Items Listed or still Loading items')],
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Items"),
        ),
        body: body);
  }
}
