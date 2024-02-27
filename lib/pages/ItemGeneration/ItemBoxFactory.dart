import 'package:flutter/material.dart';
import 'item.dart';
import 'ItemBox.dart';
import 'WebItemBox.dart';
import 'MobileItemBox.dart';

class ItemBoxFactory {
  late ItemBox item;
  makeItemBox(Item data, BuildContext context) {
    bool isWeb = Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS;
    isWeb
        ? item = WebItemBox(itemData: data, context: context)
        : item = MobileItemBox(itemData: data, context: context);
    return item;
  }
}
