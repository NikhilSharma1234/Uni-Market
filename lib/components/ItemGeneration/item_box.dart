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

    Color conditionColor = conditionBackground[item.condition]!;

    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: InkWell(
            // for future use to link each item to a unique page based on its id
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ItemPage(data: item),
                ),
              );
            },
            child: Stack(children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      // border: Border.all(color: style.colorScheme.onPrimary),
                      color: style.colorScheme.background.withOpacity(0.25),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade700.withOpacity(0.25)
                                  : Colors.black.withOpacity(0.25),
                          spreadRadius: 3,
                          blurRadius: 4,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                            child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                child: AspectRatio(
                                  aspectRatio: 30 / 26,
                                  child: Image.network(
                                    item.imagePath[0],
                                    fit: BoxFit.fitWidth,
                                    // height: screenWidth * 0.1,
                                  ),
                                ))),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Text(item.name,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          overflow: TextOverflow.ellipsis)),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          color:
                                              conditionColor.withOpacity(0.75)),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 3),
                                        child: Text(
                                            '${item.condition[0]}${item.condition.substring(1).toLowerCase()}',
                                            style:
                                                const TextStyle(fontSize: 20)),
                                      ),
                                    )),
                              )
                            ]),
                      ],
                    ),
                  )),
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return _buildPriceIndicatior(constraints.maxWidth * 0.25,
                    constraints.maxHeight * 0.1, '\$${item.price}');
              }),
            ])));
  }

  Widget _buildPriceIndicatior(double width, double height, String itemPrice) {
    return Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomRight: Radius.circular(10)),
                    color: Theme.of(context).colorScheme.background),
                child: FittedBox(
                    fit: BoxFit.contain,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Text(
                          itemPrice,
                          textAlign: TextAlign.center,
                        ))))));
  }
}
