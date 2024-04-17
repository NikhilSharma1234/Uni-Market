import 'package:flutter/material.dart';
import 'package:uni_market/components/ItemGeneration/item_box_factory.dart';
import 'item.dart';

class AbstractItemFactory {
  ItemBoxFactory itemFactory = ItemBoxFactory();

  buildItemBox(Item data, BuildContext context, [noAction]) {
    return itemFactory.makeItemBox(data, context, noAction);
  }
}
