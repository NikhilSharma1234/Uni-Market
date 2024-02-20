import 'package:flutter/material.dart';
import 'package:uni_market/pages/item_page.dart';
import 'ItemBox.dart';
import 'item.dart';
import 'Styles/Style.dart';
import 'Styles/BookStyle.dart';
import 'Styles/DefaultStyle.dart';
import 'Styles/KitStyle.dart';

class WebItemBox extends ItemBox {
  @override
  final Item itemData;
  @override
  final BuildContext context;

  const WebItemBox({Key? key, required this.itemData, required this.context})
      : super(key: key, itemData: itemData, context: context);

  @override
  State<WebItemBox> createState() => _WebItemBoxState();
}

class _WebItemBoxState extends State<WebItemBox> {
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

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenHeight * 0.015;

    return InkWell(
        // for future use to link each item to a unique page based on its id
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ItemPage(data: item),
              ),
            );
        },
        child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Stack(children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: style.colorScheme.onPrimary),
                      color: style.colorScheme.background,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            flex: 8,
                            child: Center(
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: item.imagePath.isEmpty ? Image.network('https://st4.depositphotos.com/14953852/22772/v/450/depositphotos_227724992-stock-illustration-image-available-icon-flat-vector.jpg', fit: BoxFit.fitWidth,)
                                    : Image.network(
                                      item.imagePath[0], // TODO may not need depending on fix in search
                                      fit: BoxFit.fitWidth,
                                      // height: screenWidth * 0.1,
                                    )))),
                        Flexible(
                            flex: 1,
                            child: Center(
                                child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(item.name))))
                      ],
                    ),
                  )),
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return _buildPriceIndicatior(constraints.maxWidth * 0.18,
                    constraints.maxHeight * 0.08, '\$${item.price}');
              }),
            ])));
  }

  Widget _buildPriceIndicatior(double width, double height, String itemPrice) {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
            padding: const EdgeInsets.only(left: 1, top: 1),
            child: SizedBox(
                width: width,
                height: height,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(10)),
                        color: Colors.grey.shade800),
                    child: FittedBox(
                        fit: BoxFit.contain,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 1),
                            child: Text(
                              itemPrice,
                              textAlign: TextAlign.center,
                            )))))));
  }
}
