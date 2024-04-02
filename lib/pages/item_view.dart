import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/ItemGeneration/abstract_item_factory.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/helpers/functions.dart';

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
  late List<Widget> items = [
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 16)),
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Awaiting result...'),
          ),
        ],
      ),
    )
  ];
  var db = FirebaseFirestore.instance;
  AbstractItemFactory factory = AbstractItemFactory();

  getItems() async {
    // takes super long for some reason
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
          if (items.isEmpty) {
            items = [const Text("No Items Listed")];
          } else {
            items = value;
          }
        })));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (widget.sellerID == null) {
      items = [const Text("Issue getting user")];
    }

    Widget body;

    body = GridView.count(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        crossAxisCount: (screenWidth / 320).round(),
        childAspectRatio: 20 / 23,
        children: items);

    // if (items.isEmpty) {
    //   body = const Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[Text('No Items Listed or still Loading items')],
    //     ),
    //   );
    // }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Items"),
        ),
        body: body);
  }
}
