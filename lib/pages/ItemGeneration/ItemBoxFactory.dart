import 'package:flutter/material.dart';
import 'item.dart';
import 'ItemBox.dart';

class ItemBoxFactory {
  late ItemBox item;
  makeItemBox(Data data, BuildContext context) {
    return ItemBox(itemData: data, context: context);
  }
}
