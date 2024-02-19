import 'package:flutter/material.dart';
import 'item.dart';

abstract class ItemBox extends StatefulWidget {
  // DataSnapshot snapshot; for when database is actually usable
  final Item itemData;
  // final Style style;
  final BuildContext context;

  const ItemBox({Key? key, required this.itemData, required this.context})
      : super(key: key);
}
