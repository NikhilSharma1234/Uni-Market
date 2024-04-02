import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_market/components/ItemGeneration/abstract_item_factory.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/helpers/theme_provider.dart';
import 'package:uni_market/pages/item_page.dart';
import 'package:uni_market/data_store.dart' as data_store;

class WishList extends StatefulWidget {
  final List listOfItemIds;
  const WishList({
    required this.listOfItemIds,
    Key? key,
  }) : super(key: key);

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  late Stream<List<Widget>> itemStream;
  AbstractItemFactory factory = AbstractItemFactory();
  itemsWidth(double screenWidth) {
    if (screenWidth < 500) {
      return (screenWidth - (screenWidth * 0.06));
    }
    if (screenWidth < 650) {
      return (screenWidth - (screenWidth * 0.06)) / 2;
    }
    if (screenWidth < 1000) {
      return (screenWidth - (screenWidth * 0.06)) / 3;
    }
    if (screenWidth < 1300) {
      return (screenWidth - (screenWidth * 0.06)) / 4;
    }
    if (screenWidth < 1600) {
      return (screenWidth - (screenWidth * 0.06)) / 5;
    }
    if (screenWidth < 2000) {
      return (screenWidth - (screenWidth * 0.06)) / 6;
    }
    if (screenWidth < 2400) {
      return (screenWidth - (screenWidth * 0.06)) / 7;
    }
    return (screenWidth - (screenWidth * 0.06)) / 4;
  }

  Map<String, Color> conditionBackground = {
    "NEW": Colors.green,
    "USED": Colors.orange,
    "WORN": Colors.red
  };

  Future<Widget> generateItemWidget(itemId, darkModeOn) async {
    var itemFromFirebase =
        await FirebaseFirestore.instance.collection("items").doc(itemId).get();
    if (itemFromFirebase.data() != null) {
      var item = itemFromFirebase.data();
      item?['id'] = itemFromFirebase.id; // adding id to data
      if (item?['images'].length == 0) {
        item?['images'].add(await FirebaseStorage.instance
            .ref("images/missing_image.jpg")
            .getDownloadURL());
      } else {
        for (int i = 0; i < item?['images'].length; i++) {
          item?['images'][i] = await getURL(item['images'][i]);
        }
      }
      try {
        // ignore: use_build_context_synchronously
        return factory.buildItemBox(Item.fromFirebase(item!), context);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    return const SizedBox(
      width: 30,
      child: Text('Abasad'),
    );
  }

  Future<String> getURL(String imageURL) async {
    String image;
    try {
      image = await FirebaseStorage.instance.ref(imageURL).getDownloadURL();
    } catch (e) {
      image = "Missing Image";
    }
    return image;
  }

  Future<List<Widget>> generateItems(itemIds, darkModeOn) async {
    List<Widget> itemsList = [];
    for (var id in itemIds) {
      var item = await generateItemWidget(id, darkModeOn);
      itemsList.add(item);
    }
    return itemsList;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    bool darkModeOn =
        // ignore: use_build_context_synchronously
        Provider.of<ThemeProvider>(context, listen: true).themeMode ==
            ThemeMode.dark;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Wishlist Items"),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(data_store.user.email)
              .snapshots(),
          builder: (context, streamSnapshot) {
            if (streamSnapshot.hasData) {
              return FutureBuilder(
                  future: generateItems(
                      streamSnapshot.data!['wishlist'], darkModeOn),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.hasData) {
                      var items = futureSnapshot.data ?? [const SizedBox()];
                      return GridView.count(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        crossAxisCount: (screenWidth / 320).floor(),
                        childAspectRatio: 20 / 23,
                        children: items,
                      );
                    }
                    return const Row(
                      children: [
                        Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  });
            }
            return const Row(
              children: [
                Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          },
        ));
  }
}
