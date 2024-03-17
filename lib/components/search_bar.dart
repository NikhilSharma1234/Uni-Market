import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/components/ItemGeneration/abstract_item_factory.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:typesense/typesense.dart';
import 'package:http/http.dart' as http;

class ItemSearchBar extends StatefulWidget {
  // passing a function from the parent down so we can use its setState to redraw the items
  final Function(List<Widget> newItems, bool append) setPageState;
  final Function(String) updateSearchText;
  final Filters filter;

  // final Filters filters;

  // requiring the function
  const ItemSearchBar(
      {super.key,
      required this.setPageState,
      required this.updateSearchText,
      required this.filter});

  @override
  State<ItemSearchBar> createState() => _ItemSearchBarState();
}

class _ItemSearchBarState extends State<ItemSearchBar> {
  bool isDark = true;
  late String searchVal;
  final SearchController controller = SearchController();
  List<ListTile> suggestions = [];

  SearchPageController ctrl = SearchPageController();

  void updateSuggestions(String typedText) {
    setState(() {
      suggestions = List<ListTile>.generate(5, (int index) {
        final String item = '$typedText$index';
        return ListTile(
          title: Text(item),
          onTap: () {
            setState(() {
              // todo later: update the search function to include the now passed in filters using widget.filters
              ctrl.search(item, 30, context, widget.filter).then((value) {
                widget.setPageState(value, false);
              });
              controller.closeView(item);
            });
          },
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FocusScopeNode focusNode = FocusScopeNode();

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FocusScope(
            // this fixes the issues with unfocusing while text still selected
            node: focusNode,
            onFocusChange: (isFocused) {
              focusNode.unfocus();
            },
            child: SearchAnchor.bar(
                barHintText: "Search items",
                searchController: controller,
                onSubmitted: (value) {
                  ctrl.search(value, 30, context, widget.filter).then((value) {
                    widget.setPageState(value, false);
                  });
                  controller.closeView(value);
                  FocusScope.of(context).unfocus();
                },
                onChanged: (value) {
                  updateSuggestions(value);
                  widget.updateSearchText(value);
                },
                suggestionsBuilder: (BuildContext context, controller) {
                  return suggestions;
                })));
  }
}

class SearchPageController {
  AbstractItemFactory factory = AbstractItemFactory();
  search(String searchTerm, int number, BuildContext context,
      Filters filter) async {
    List<Widget> widgets = [];
    var host = "34.125.158.70";
    var API_KEY = '5RxNLWNEwIFn706Yz4nJw2CFfNaaQHJmfuVjUVgIT3OMfPhT';
    final config = Configuration(
      'eSMjP8YVxHdMKoT164TTKLMkXRS47FdDnPENNAA2Ob8RfEfr',
      nodes: {
        Node(
          Protocol.https,
          "hawk-perfect-frog.ngrok-free.app",
          port: 443, // stuff provided by the cloud hosting
        ),
      },
      // numRetries: 3, // A total of 4 tries (1 original try + 3 retries)
      connectionTimeout: const Duration(seconds: 2),
    );

    final client = Client(config);

    String filterString = 'price:[${filter.lowerPrice}..${filter.upperPrice}]';

    String sort = '';

    switch (filter.sort) {
      case Sort.newestToOldest:
        sort = 'dateListed:desc';
        break;
      case Sort.oldestToNewest:
        sort = 'dateListed:asc';
        break;
      case Sort.highToLow:
        sort = 'price:desc';
        break;
      case Sort.lowToHigh:
        sort = 'price:asc';
        break;
      default:
        break;
    }

    switch (filter.condition) {
      case Condition.newItem:
        filterString += ' && condition:NEW';
        break;
      case Condition.usedItem:
        filterString += ' && condition:USED';
        break;
      case Condition.wornItem:
        filterString += ' && condition:WORN';
        break;
      case Condition.none:
        break;
    }

    final searchParameters = {
      'q': searchTerm,
      'query_by': 'name',
      'sort_by': sort,
      'filter_by': filterString,
    };

    String search_type = "name";

    // await client.collecton('items2').documents.search(searchParameters);

    // final Map<String, dynamic> data =
    //     await client.collection('items').documents.search(searchParameters);

    final typesense_key = 'eSMjP8YVxHdMKoT164TTKLMkXRS47FdDnPENNAA2Ob8RfEfr';

    String url = "https://6bdc-71-89-244-12.ngrok-free.app/collections/items2";

    Uri search_url = Uri.parse(
        "$url/documents/search?q=$searchTerm&query_by=$search_type&sort_by=$sort&filter_by=$filterString");
    search_url =
        Uri.parse("$url/documents/search?q=test&query_by=$search_type");
    final Map<String, String> headers = {
      'Access-Control-Allow-Methods': 'true',
      "X-TYPESENSE-API-KEY": typesense_key,
    };

    Map<String, dynamic> data = {};

    try {
      // search typesense
      final response = await http.get(search_url, headers: headers);

      if (response.statusCode == 200) {
        // Decode the JSON response
        data = json.decode(response.body) as Map<String, dynamic>;
      } else {
        // Handle error
        throw Exception('Failed to fetch items: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }

    print(data);

    if (context.mounted) {
      // widgets = await generateItems(data, context);
    } else {
      if (kDebugMode) {
        print("no clue as to whats going on, buildcontext wasnt mounded");
      }
    }

    return widgets;
  }

  Future<String> getURL(
    String imageURL,
  ) async {
    String image;
    try {
      image = await FirebaseStorage.instance.ref(imageURL).getDownloadURL();
    } catch (e) {
      image = await FirebaseStorage.instance
          .ref("images/missing_image.jpg")
          .getDownloadURL();
    }
    return image;
  }

  generateItems(Map<String, dynamic> data, BuildContext context) async {
    List<Widget> widgets = [];
    for (var item in data['hits']) {
      if (item['document']['images'].length == 0) {
        item['document']['images'].add(await FirebaseStorage.instance
            .ref("images/missing_image.jpg")
            .getDownloadURL());
      } else {
        for (int i = 0; i < item['document']['images'].length; i++) {
          item['document']['images'][i] =
              await getURL(item['document']['images'][i]);
        }
      }

      if (context.mounted) {
        widgets.add(factory.buildItemBox(
            Item.fromJSON(item['document']), context)); // this is the issue
      }
    }
    return widgets;
  }
}
