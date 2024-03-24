import 'package:flutter/material.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:uni_market/helpers/functions.dart';

class ItemSearchBar extends StatefulWidget {
  // passing a function from the parent down so we can use its setState to redraw the items
  final Function(List<Widget> newItems, bool append) setPageState;
  final Function(String) updateSearchText;
  final Filters filter;

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

  void updateSuggestions(String typedText) {
    searchSuggestions(typedText, 5).then((value) {
      setState(() {
        suggestions = List<ListTile>.generate(5, (int index) {
          final String item = value[index];
          return ListTile(
            title: Text(item),
            onTap: () {
              setState(() {
                // todo later: update the search function to include the now passed in filters using widget.filters
                search(item, 30, context, widget.filter).then((value) {
                  widget.setPageState(value, false);
                });
                controller.closeView(item);
              });
            },
          );
        });
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
                  widget.setPageState([], false);
                  search(value, 30, context, widget.filter).then((value) {
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
