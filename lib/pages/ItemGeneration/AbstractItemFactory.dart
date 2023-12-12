import 'package:flutter/material.dart';
import 'ItemBoxFactory.dart';
import 'data.dart';

class AbstractItemFactory {
  ItemBoxFactory itemFactory = ItemBoxFactory();

  // Widget buildItemBox(DataSnapshot snapshot, String name, BuildContext context) {
  buildItemBox(Data data, BuildContext context) {
    return itemFactory.makeItemBox(data, context);
  }
}
