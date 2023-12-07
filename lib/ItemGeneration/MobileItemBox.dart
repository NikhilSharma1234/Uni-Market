import 'package:flutter/material.dart';
import 'ItemBox.dart';
import 'data.dart';
import 'Styles/Style.dart';
import 'Styles/BookStyle.dart';
import 'Styles/DefaultStyle.dart';

class MobileItemBox extends ItemBox {
  @override
  final Data itemData;
  @override
  final BuildContext context;

  const MobileItemBox({Key? key, required this.itemData, required this.context})
      : super(key: key, itemData: itemData, context: context);

  @override
  State<MobileItemBox> createState() => _MobileItemBoxState();
}

class _MobileItemBoxState extends State<MobileItemBox> {
  late Style style;

  @override
  Widget build(BuildContext context) {
    Map<String, Style> styleType = {
      "Book": BookStyle(context: context),
      "Default": DefaultStyle(context: context)
    };

    // getting the correct style type - maybe combine colors down the line?
    bool found = false;
    for (var key in styleType.keys) {
      if (widget.itemData.tags.contains(key)) {
        style = styleType[key]!;
        found = true;
        break;
      }
    }
    if (!found) {
      style = styleType["Default"]!;
    }

    // use the style here when creating box
    return SizedBox(
        width: 10,
        child: Text(
          widget.itemData.name,
          style: style.getThemeData().textTheme.headlineMedium,
        ));
  }
}
