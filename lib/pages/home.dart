import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'ItemGeneration/item.dart';
import 'ItemGeneration/AbstractItemFactory.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';
import 'package:uni_market/pages/posting_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:typesense/typesense.dart';
import 'dart:convert';

// I KNOW THIS IS BAD PRACTICE I DO NOT CARE RN I JUST WANT TO GET THIS WORKING (search only)
const typeSenseAPIKey = "oR9PTRdUpGBUI3CbbKLLS16JtYavUU44";

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> items = [const Text("")];
  String searchVal = "";

  // redraws the items on the page based on search results
  redrawItems(List<Widget> newItems, bool append) {
    setState(() {
      append ? items = items + newItems : items = newItems;
    });
  }

  // callback to keep up to date search text stored here.
  updateSearchText(String text) {
    setState(() {
      searchVal = text;
    });
  }

  // filter stuff
  Filters filter = Filters.none();
  final lowerPrice = TextEditingController();
  final upperPrice = TextEditingController();

  void clearFilters() {
    setState(() {
      filter = Filters.none();
      lowerPrice.value = TextEditingValue.empty;
      upperPrice.value = TextEditingValue.empty;
    });
  }

  // not sure if Im going to be able to get this to work, but its a stand in for when the filters get applied
  void applyFilters() {
    PageController ctrl = PageController();
    ctrl.search(searchVal, 30, context, filter).then((value) {
      redrawItems(value, false);
    });
  }

  // called just after initstate, used to set the initial items displayed
  @override
  void didChangeDependencies() async {
    PageController ctrl = PageController();
    ctrl.search("", 30, context, filter).then((value) {
      redrawItems(value, false);
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Widget body = GridView.count(
      crossAxisCount: (screenWidth / 320).round(),
      childAspectRatio: 2 / 2,
      children: items,
    );

    if (items.isEmpty) {
      body =
          const Text("Didnt find any items :(", style: TextStyle(fontSize: 20));
    }

    var radioValue;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: kIsWeb
            ? UserNavBarDesktop(
                redrawItems: redrawItems,
                updateSearchText: updateSearchText,
                filter: filter)
            : null,
        bottomNavigationBar:
            !kIsWeb ? const UserNavBarMobile(activeIndex: 0) : null,
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => const Dialog(
                    insetPadding: EdgeInsets.all(0),
                    child: PostingPage(),
                  )),
          child: const Icon(Icons.add),
        ),
        drawer: Theme(
            data: Theme.of(context).copyWith(cardColor: Colors.blueGrey),
            child: Drawer(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 55),
                          child: Container(
                              color: Theme.of(context).primaryColor,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text("Price Range")),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: lowerPrice,
                                          onChanged: ((value) {
                                            if (value != "") {
                                              filter.lowerPrice =
                                                  int.parse(lowerPrice.text);
                                            } else {
                                              filter.lowerPrice = 0;
                                            }
                                          }),
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Lower",
                                          ),
                                        )),
                                        Expanded(
                                            child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: upperPrice,
                                          onChanged: ((value) {
                                            if (value != "") {
                                              filter.upperPrice =
                                                  int.parse(upperPrice.text);
                                            } else {
                                              filter.upperPrice = 100000;
                                            }
                                          }),
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Upper",
                                          ),
                                        ))
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: DropdownMenu(
                                          onSelected: (value) =>
                                              filter.sort = value as Sort,
                                          initialSelection: filter.sort,
                                          dropdownMenuEntries: const [
                                            DropdownMenuEntry(
                                                value: Sort.highToLow,
                                                label: 'High to Low'),
                                            DropdownMenuEntry(
                                                value: Sort.lowToHigh,
                                                label: 'Low to High'),
                                            DropdownMenuEntry(
                                                value: Sort.bestMatch,
                                                label: 'Best Match')
                                          ]),
                                    ),
                                    ListTile(
                                        title: const Text("New"),
                                        leading: Radio<Condition>(
                                            value: Condition.newItem,
                                            groupValue: filter.condition,
                                            onChanged: (value) {
                                              setState(() {
                                                filter.condition = value!;
                                              });
                                            })),
                                    ListTile(
                                        title: const Text("Used"),
                                        leading: Radio<Condition>(
                                            value: Condition.usedItem,
                                            groupValue: filter.condition,
                                            onChanged: (value) {
                                              setState(() {
                                                filter.condition = value!;
                                              });
                                            })),
                                    ListTile(
                                        title: const Text("Worn"),
                                        leading: Radio<Condition>(
                                            value: Condition.wornItem,
                                            groupValue: filter.condition,
                                            onChanged: (value) {
                                              setState(() {
                                                filter.condition = value!;
                                              });
                                            })),

                                    // const Padding(
                                    //     padding: EdgeInsets.all(5),
                                    //     child: Text("Tags")),
                                    // CheckboxListTile(
                                    //     title: const Text("Kit"),
                                    //     value: filter.tags[0],
                                    //     onChanged: (value) => setState(
                                    //         () => filter.tags[0] = value)),
                                    // CheckboxListTile(
                                    //     title: const Text("Desk"),
                                    //     value: filter.tags[1],
                                    //     onChanged: (value) => setState(
                                    //         () => filter.tags[1] = value)),
                                    // CheckboxListTile(
                                    //     title: const Text("Computer"),
                                    //     value: filter.tags[2],
                                    //     onChanged: (value) => setState(
                                    //         () => filter.tags[2] = value)),
                                    Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: TextButton(
                                            style: const ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll<
                                                      Color>(Colors.green),
                                            ),
                                            onPressed: () {
                                              applyFilters();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Apply Filters')))
                                  ])),
                        ),
                      ]),
                ))),
        body: body);
  }
}

class MySearchBar extends StatefulWidget {
  // passing a function from the parent down so we can use its setState to redraw the items
  final Function(List<Widget> newItems, bool append) setPageState;
  final Function(String) updateSearchText;
  final Filters filter;

  // final Filters filters;

  // requiring the function
  const MySearchBar(
      {super.key,
      required this.setPageState,
      required this.updateSearchText,
      required this.filter});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  bool isDark = true;
  late String searchVal;
  final SearchController controller = SearchController();
  List<ListTile> suggestions = [];

  PageController ctrl = PageController();

  void updateSuggestions(String typedText) {
    setState(() {
      suggestions = List<ListTile>.generate(5, (int index) {
        final String item = '$typedText$index';
        return ListTile(
          title: Text(item),
          onTap: () {
            setState(() {
              // TODO - update the search function to include the now passed in filters using widget.filters
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchAnchor(
          searchController: controller,
          // viewOnSubmited and viewOnChanged added via this PR: https://github.com/flutter/flutter/pull/136840, allows us to grab submitted and changed values
          viewOnSubmitted: (value) {
            // redraw the page when the search has been done
            ctrl.search(value, 30, context, widget.filter).then((value) {
              widget.setPageState(value, false);
            });
            controller.closeView(value);
          },
          viewOnChanged: (value) {
            updateSuggestions(value);
            widget.updateSearchText(value);
          },
          builder: (BuildContext context, controller) {
            // attempting to get the search bar to take an enter key to submit search
            return SearchBar(
              controller: controller,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onTap: () {
                controller.openView();
              },
              leading: const Icon(Icons.search),
            );
          },
          suggestionsBuilder: (BuildContext context, controller) {
            return suggestions;
          }),
    );
  }
}

class PageController {
  AbstractItemFactory factory = AbstractItemFactory();
  search(String searchTerm, int number, BuildContext context,
      Filters filter) async {
    List<Widget> widgets = [];
    final config = Configuration(
      typeSenseAPIKey,
      nodes: {
        Node(
          Protocol.https,
          "vzlsy6kriwp0at9bp-1.a1.typesense.net",
          port: 443, // stuff provided by the cloud hosting
        ),
      },
      // numRetries: 3, // A total of 4 tries (1 original try + 3 retries)
      connectionTimeout: const Duration(seconds: 2),
    );

    final client = Client(config);

    String filterString = 'price:[${filter.lowerPrice}..${filter.upperPrice}]';

    String sort = '';
    if (filter.sort == Sort.highToLow) {
      sort = 'price:desc';
    } else if (filter.sort == Sort.lowToHigh) {
      sort = 'price:asc';
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
      'query_by': 'embedding',
      'sort_by': sort,
      'filter_by': filterString,
    };
    final Map<String, dynamic> data =
        await client.collection('items').documents.search(searchParameters);
    if (context.mounted) {
      widgets = await generateItems(data, context);
    } else {
      print("no clue as to whats going on, buildcontext wasnt mounded");
    }

    return widgets;
  }

  generateItems(Map<String, dynamic> data, BuildContext context) async {
    List<Widget> widgets = [];
    for (var item in data['hits']) {
      if (item['document']['images'].length == 0) {
        item['document']['images'].add(await FirebaseStorage.instance
            .ref("images/missing_image.jpg")
            .getDownloadURL());
      } else {
        item['document']['images'][0] = await FirebaseStorage.instance
            .ref(item['document']['images'][0])
            .getDownloadURL();
      }

      if (context.mounted) {
        widgets.add(factory.buildItemBox(
            Item.fromJSON(item['document']), context)); // this is the issue
      }
    }
    return widgets;
  }
}
