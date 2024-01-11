import 'package:flutter/material.dart';
import 'ItemBox.dart';
import 'data.dart';
import 'Styles/Style.dart';
import 'Styles/BookStyle.dart';
import 'Styles/DefaultStyle.dart';
import 'Styles/KitStyle.dart';

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
  late Style theme;

  @override
  Widget build(BuildContext context) {
    Map<String, Style> styleType = {
      "book": BookStyle(context: context),
      "default": DefaultStyle(context: context),
      "kit": KitStyle(context: context)
    };

    // getting the correct style type - maybe combine colors down the line?
    bool found = false;
    for (var key in styleType.keys) {
      if (widget.itemData.tags.contains(key)) {
        theme = styleType[key]!;
        found = true;
        break;
      }
    }
    if (!found) {
      theme = styleType["default"]!;
    }

    var style = theme.getThemeData();
    var item = widget.itemData;

    // use the style here when creating box
    return InkWell(
        // for future use to link each item to a unique page based on its id
        // onTap: () {
        //   Navigator.pushReplacementNamed(context, "$id");
        // },
        child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlue),
                    color: style.colorScheme.background),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Image.asset(item.imagePath)),
                      Center(
                          child: Text(item.name,
                              style: const TextStyle(fontSize: 20))),
                    ],
                  ),
                ))));
  }
}