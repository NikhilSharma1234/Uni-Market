import 'package:flutter/material.dart';
import 'item.dart';
import 'item_box.dart';

class ItemBoxFactory {
  late ItemBox item;
  makeItemBox(Item data, BuildContext context, [noAction]) {
    return ItemBox(
        itemData: data, context: context, noAction: noAction ?? false);
  }
}
