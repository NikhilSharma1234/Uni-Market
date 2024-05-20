import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:intl/intl.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/data_store.dart';
import 'package:uni_market/data_store.dart' as data_store;

class ItemPageInfo extends StatefulWidget {
  final Item itemData;
  final String sellerName;
  final String sellerProfilePic;
  final int? sellerItemsBought;
  final int? sellerItemsSold;
  final bool noAction;

  const ItemPageInfo(
      {Key? key,
      required this.itemData,
      required this.sellerName,
      required this.sellerProfilePic,
      required this.sellerItemsBought,
      required this.sellerItemsSold,
      required this.noAction})
      : super(key: key);

  @override
  State<ItemPageInfo> createState() => _ItemPageInfoState();
}

class _ItemPageInfoState extends State<ItemPageInfo> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Widget itemButton = ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(shape: const BeveledRectangleBorder()),
      child: const Text('Contact Seller'),
    );
    if (user.email == widget.itemData.sellerId) {
      itemButton = ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          shape: const BeveledRectangleBorder(),
          backgroundColor: Colors.red,
        ),
        child: const Text('Delete Post'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.itemData.name,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Text('\$${widget.itemData.price}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start),
              ),
              Text(
                  'Listed ${DateFormat('yMd').format(widget.itemData.createdAt)} at ${widget.itemData.schoolId}',
                  style: const TextStyle(fontSize: 16)),
              Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: loading
                      ? const CircularProgressIndicator()
                      : Row(
                          children: widget.itemData.deletedAt != null &&
                                  widget.itemData.sellerId ==
                                      data_store.user.email
                              ? [
                                  const Text(
                                    'This item was deleted.',
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.red),
                                  )
                                ]
                              : [
                                  itemButton,
                                  IconButton(
                                      icon: const Icon(Icons.favorite),
                                      selectedIcon: const Icon(Icons.favorite,
                                          color: Colors.red),
                                      iconSize: 36,
                                      tooltip: 'Add to wishlist',
                                      isSelected: data_store.user.wishlist
                                          .contains(widget.itemData.id),
                                      onPressed: null),
                                  IconButton(
                                      icon: const Icon(
                                          Icons.report_problem_rounded),
                                      selectedIcon: const Icon(
                                          Icons.report_problem_rounded,
                                          color: Colors.orange),
                                      iconSize: 36,
                                      tooltip: widget.itemData.isFlagged
                                          ? 'Item is under review'
                                          : 'Report Item',
                                      isSelected: widget.itemData.isFlagged,
                                      onPressed: null),
                                ],
                        )),
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('About the product',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child:
                    Text('Product Description: ${widget.itemData.description}'),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Product Tags:'),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    for (var tag in widget.itemData.tags)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Chip(
                          label: Text(tag),
                        ),
                      )
                  ]),
              const Padding(padding: EdgeInsets.only(top: 8), child: Divider()),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Seller Information',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: AdvancedAvatar(
                        size: 96,
                        image: NetworkImage(widget.sellerProfilePic),
                      ),
                    ),
                    Text('Name: ${widget.sellerName}'),
                    Text('Items Sold: ${widget.sellerItemsSold ?? 0}'),
                    Text('Items Bought: ${widget.sellerItemsBought ?? 0}'),
                    widget.itemData.sellerId != data_store.user.email
                        ? !loading
                            ? ElevatedButton(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: const BeveledRectangleBorder()),
                                child: const Text('Block this user'),
                              )
                            : const CircularProgressIndicator()
                        : const SizedBox(width: 0)
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
