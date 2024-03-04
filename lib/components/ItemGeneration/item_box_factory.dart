import 'package:flutter/material.dart';
import 'item.dart';
import 'item_box.dart';

class ItemBoxFactory {
  late ItemBox item;
  makeItemBox(Item data, BuildContext context) {
    return ItemBox(itemData: data, context: context);
  }
}
