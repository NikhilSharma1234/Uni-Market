import 'dart:async';
import 'package:flutter/foundation.dart';
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
  Timer? _debounce;

  void updateSuggestions(String typedText) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchSuggestions(typedText, 5).then((value) {
        setState(() {
          suggestions = List<ListTile>.generate(5, (int index) {
            final String item = value[index];
            return ListTile(
              title: Text(item),
              onTap: () {
                setState(() {
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
              if (kIsWeb) {
                focusNode.unfocus();
              }
            },
            child: SearchAnchor.bar(
                barElevation: MaterialStateProperty.all(0),
                barHintText: "Search items",
                viewConstraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4),
                searchController: controller,
                onSubmitted: null,
                onChanged: null,
                suggestionsBuilder: (BuildContext context, controller) {
                  return suggestions;
                  // TODO known issue: this will call but not update on the screen when text is typed, it only updates when you click on the typed text
                })));
  }
}
