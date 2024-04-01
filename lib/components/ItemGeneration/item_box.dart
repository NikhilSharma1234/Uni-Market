import 'package:flutter/material.dart';
import 'package:uni_market/pages/item_page.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/helpers/Styles/Style.dart';
import 'package:uni_market/helpers/Styles/book_style.dart';
import 'package:uni_market/helpers/Styles/default_style.dart';
import 'package:uni_market/helpers/Styles/kit_style.dart';

class ItemBox extends StatefulWidget {
  final Item itemData;
  final BuildContext context;

  const ItemBox({super.key, required this.itemData, required this.context});

  @override
  State<ItemBox> createState() => _ItemBoxState();
}

class _ItemBoxState extends State<ItemBox> {
  late Style theme;

  @override
  Widget build(BuildContext context) {
    Map<String, Style> styleType = {
      "book": BookStyle(context: context),
      "default": DefaultStyle(context: context),
      "kit": KitStyle(context: context)
    };
    Map<String, Color> conditionBackground = {
      "NEW": Colors.green,
      "USED": Colors.orange,
      "WORN": Colors.red
    };

    // getting the correct style type - maybe combine colors down the line?
    bool found = false;
    for (var key in styleType.keys) {
      if (widget.itemData.tags.contains(key)) {
        theme = styleType[key] ?? DefaultStyle(context: context);
        found = true;
        break;
      }
    }
    if (!found) {
      theme = styleType["default"] ?? DefaultStyle(context: context);
    }
    var item = widget.itemData;

    Image image;

    if (item.imagePath[0] == "NOIMAGE") {
      image = Image.asset(
        "assets/portraits/cameron.webp",
        fit: BoxFit.fitWidth,
      );
    } else {
      image = Image.network(
        item.imagePath[0],
        fit: BoxFit.fill,
      );
    }
    itemsWidth(double screenWidth) {
      if (screenWidth < 500) {
        return (screenWidth - (screenWidth * 0.06));
      }
      if (screenWidth < 650) {
        return (screenWidth - (screenWidth * 0.06)) / 2;
      }
      if (screenWidth < 1000) {
        return (screenWidth - (screenWidth * 0.06)) / 3;
      }
      if (screenWidth < 1300) {
        return (screenWidth - (screenWidth * 0.06)) / 4;
      }
      if (screenWidth < 1600) {
        return (screenWidth - (screenWidth * 0.06)) / 5;
      }
      if (screenWidth < 2000) {
        return (screenWidth - (screenWidth * 0.06)) / 6;
      }
      if (screenWidth < 2400) {
        return (screenWidth - (screenWidth * 0.06)) / 7;
      }
      return (screenWidth - (screenWidth * 0.06)) / 4;
    }

    double itemWidth = itemsWidth(MediaQuery.of(context).size.width);
    double itemHeight = itemWidth * 1.15;
    Color conditionColor = conditionBackground[item.condition] ?? Colors.black;
    return Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
            // for future use to link each item to a unique page based on its id
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ItemPage(data: item),
                ),
              );
            },
            child: Container(
                width: itemWidth,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)),
                        height: itemHeight * 0.75,
                        width: itemWidth,
                        child: image),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text(item.name,
                          style: const TextStyle(
                              fontSize: 20, overflow: TextOverflow.ellipsis)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Text(item.description,
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis)),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Text('\$${item.price.toDouble().toString()}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    overflow: TextOverflow.ellipsis)),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, bottom: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    color: conditionColor),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                  child: Text(
                                      '${item.condition[0]}${item.condition.substring(1).toLowerCase()}',
                                      style: const TextStyle(fontSize: 20)),
                                ),
                              ))
                        ]),
                  ],
                ))));
  }
}
