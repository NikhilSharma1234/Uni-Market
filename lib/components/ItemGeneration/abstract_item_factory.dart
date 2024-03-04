import 'package:flutter/material.dart';
import 'package:uni_market/components/ItemGeneration/item_box_factory.dart';
import 'item.dart';

class AbstractItemFactory {
  ItemBoxFactory itemFactory = ItemBoxFactory();

  // Widget buildItemBox(DataSnapshot snapshot, String name, BuildContext context) {
  buildItemBox(Item data, BuildContext context) {
    return itemFactory.makeItemBox(data, context);
  }
}
