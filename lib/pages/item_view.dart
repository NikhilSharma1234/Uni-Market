import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/ItemGeneration/abstract_item_factory.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import 'package:flutter/foundation.dart';

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

  late ScrollController _scrollController;

  @override
  void initState() {
    // initialize scroll controllers
    _scrollController = ScrollController();

    super.initState();
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

    if (widget.sellerID == null) {
      items = [const Text("Issue getting user")];
    }

    Widget body;

    if (kIsWeb) {
      var itemSize = screenWidth / (screenWidth / 320).round();
      for (final (index, item) in items.indexed) {
        items[index] =
            (SizedBox(width: itemSize, height: itemSize, child: item));
      }
      int rowSize = (screenWidth / 320).round();
      int numRows = (items.length / rowSize).round();
      if (numRows == 0) {
        numRows = 1;
      }

      List<Widget> rows = [];
      int currentItem = 0;
      for (var row = 0; row < numRows; row++) {
        int endIndex = currentItem + rowSize;
        if (currentItem + rowSize > items.length) {
          endIndex = items.length;
        }
        rows.add(Row(children: items.sublist(currentItem, endIndex)));
        currentItem = endIndex;
      }
      body = WebSmoothScroll(
        controller: _scrollController,
        scrollOffset: 100,
        animationDuration: 400,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _scrollController,
          child: Column(children: rows),
        ),
      );
    } else {
      body = GridView.count(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        crossAxisCount: (screenWidth / 320).round(),
        childAspectRatio: 2 / 2,
        children: items,
      );
    }

    if (items.isEmpty) {
      body = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            ),
          ],
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
