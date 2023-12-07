import 'package:flutter/material.dart';
import 'data.dart';
import 'ItemBox.dart';
import 'WebItemBox.dart';
import 'MobileItemBox.dart';

class ItemBoxFactory {
  late ItemBox item;
  makeItemBox(Data data, BuildContext context) {
    bool isWeb = Theme.of(context) == TargetPlatform.windows ||
        Theme.of(context) == TargetPlatform.macOS;
    isWeb
        ? item = MobileItemBox(itemData: data, context: context)
        : item = WebItemBox(itemData: data, context: context);

    // should build the itemBox
    return item;
  }
}
