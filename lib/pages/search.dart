import 'package:flutter/material.dart';
import 'package:uni_market/components/user_navbar.dart';
import 'ItemGeneration/data.dart';
import 'ItemGeneration/AbstractItemFactory.dart';
import 'package:flutter/services.dart';
import 'package:uni_market/helpers/filters.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:csv/csv.dart';

class SearchPage extends StatefulWidget {
  final String title;

  const SearchPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late List<Widget> items = [const Text("")];

  // redraws the items on the page based on search results - callback function for search bar
  redrawItems(List<Widget> newItems, bool append) {
    setState(() {
      append ? items = items + newItems : items = newItems;
    });
  }

  // called just after initstate, used to set the initial items displayed
  @override
  void didChangeDependencies() async {
    PageController ctrl = PageController();
    ctrl.search("", 30, context).then((value) {
      redrawItems(value, false);
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // handles loading of items
    Widget body = GridView.count(
      crossAxisCount: (screenWidth / 320).round(),
      childAspectRatio: 2 / 2,
      children: items,
    );
    if (items.isEmpty) {
      body =
          const Text("Didnt find any items :(", style: TextStyle(fontSize: 20));
    }

    // filter stuff
    Filters filter = Filters(0, 999999999, [false, false, false]);
    final lowerPrice = TextEditingController();
    final upperPrice = TextEditingController();

    void clearFilters() {
      setState(() {
        filter = Filters(0, 999999999, [false, false, false]);
        lowerPrice.value = TextEditingValue.empty;
        upperPrice.value = TextEditingValue.empty;
      });
    }

    // not sure if Im going to be able to get this to work, but its a stand in for when the filters get applied
    void applyFilters() {}

    return Scaffold(
      appBar: const UserNavBar(),
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
                                          filter.lowerPrice =
                                              int.parse(lowerPrice.text);
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
                                          filter.upperPrice =
                                              int.parse(upperPrice.text);
                                        }),
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Upper",
                                        ),
                                      ))
                                    ],
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Text("Tags")),
                                  CheckboxListTile(
                                      title: const Text("Kit"),
                                      value: filter.tags[0],
                                      onChanged: (value) => setState(
                                          () => filter.tags[0] = value)),
                                  CheckboxListTile(
                                      title: const Text("Desk"),
                                      value: filter.tags[1],
                                      onChanged: (value) => setState(
                                          () => filter.tags[1] = value)),
                                  CheckboxListTile(
                                      title: const Text("Computer"),
                                      value: filter.tags[2],
                                      onChanged: (value) => setState(
                                          () => filter.tags[2] = value)),
                                  Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: TextButton(
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll<Color>(
                                                    Colors.green),
                                          ),
                                          onPressed: () =>
                                              applyFilters(), // use this to call a function to update filters
                                          child: const Text('Apply Filters')))
                                ])),
                      ),
                    ]),
              ))),
      body: Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
        Expanded(
            flex: 10,
            child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(
                      builder: (context) => TextButton(
                          style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll<Color>(
                                Colors.blueAccent),
                          ),
                          onPressed: () => Scaffold.of(context)
                              .openDrawer(), // use this to call a function to update filters
                          child: const Text('Open Filters'))),
                  SizedBox(
                      width: .5 * screenWidth,
                      child: MySearchBar(
                          setPageState: redrawItems, filters: filter)),
                  TextButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(Colors.red),
                      ),
                      onPressed: () =>
                          clearFilters(), // use this to call a function to update filters
                      child: const Text('Clear Filters'))
                ],
              ),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: body))
            ])),
      ]),
    );
  }
}

class MySearchBar extends StatefulWidget {
  // passing a function from the parent down so we can use its setState to redraw the items
  final Function(List<Widget> newItems, bool append) setPageState;

  final Filters filters;

  // requiring the function
  const MySearchBar(
      {super.key, required this.setPageState, required this.filters});

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
              ctrl.search(item, 30, context).then((value) {
                widget.setPageState(value, false);
              });
              controller.closeView(item);
            });
          },
        );
      });
    });
  }

  String getText() {
    return controller.text;
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
            ctrl.search(value, 30, context).then((value) {
              widget.setPageState(value, false);
            });
            controller.closeView(value);
          },
          viewOnChanged: (value) {
            updateSuggestions(value);
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
  ItemModel model = ItemModel();

  search(String searchTerm, int number, BuildContext context) async {
    return await generateItems(searchTerm, number, context);
  }

  generateItems(String searchTerm, int num, BuildContext context) async {
    List<Widget> widgets = [];
    int i = 0;
    for (Data item in await model.getData('assets/items.csv', num)) {
      if (!item.tags.contains(searchTerm.toLowerCase()) &&
          !item.name.toLowerCase().contains(searchTerm.toLowerCase()) &&
          searchTerm != "") {
        continue;
      }
      if (i >= num) {
        break;
      }
      if (context.mounted) {
        widgets.add(factory.buildItemBox(item, context));
        i++;
      }
    }
    return widgets;
  }
}

class ItemModel {
  // get the data from the text file
  getData(String fileName, int num) async {
    List<Data> items = [];
    int numLines = num;
    var rawFileString = await rootBundle.loadString(fileName);
    // return rawFileString;
    List<List<dynamic>> dataFile =
        const CsvToListConverter().convert(rawFileString);

    for (var field in dataFile) {
      // do a certain number of lines
      if (numLines == 0) {
        break;
      }
      items.add(Data(field[0], field[1], field[2], field[3], field[4],
          List<String>.from(field.sublist(5))));
      numLines -= 1;
    }
    return items;
  }
}

generateFakeItems(int num, BuildContext context) {
  List<Widget> items = [];
  for (int i = 0; i < num; i++) {
    // temporary bit for testing
    items.add(Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        child: Center(
          child: Text(
            "Text",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        )));
  }
  return items;
}

// I was working on an expansionpanel list on the side of the main page in the body but pivoted to the drawer approach, saving this in case we decide to go back to it

//   List<bool> _isOpen = [true, false, false];
// ExpansionPanelList(
//                                   dividerColor: Colors.black,
//                                   expandIconColor: Colors.white,
//                                   expandedHeaderPadding:
//                                       const EdgeInsets.all(0),
//                                   materialGapSize: 0,
//                                   children: [
//                                     ExpansionPanel(
//                                         headerBuilder: (BuildContext context,
//                                             bool isOpen) {
//                                           return const Text("Price");
//                                         },
//                                         body: Row(children: [
//                                           Expanded(
//                                               child: TextField(
//                                             controller: lowerPrice,
//                                             decoration: const InputDecoration(
//                                               border: OutlineInputBorder(),
//                                               labelText: "Lower",
//                                             ),
//                                           )),
//                                           Expanded(
//                                               child: TextField(
//                                             controller: upperPrice,
//                                             decoration: const InputDecoration(
//                                               border: OutlineInputBorder(),
//                                               labelText: "Upper",
//                                             ),
//                                           )),
//                                         ]),
//                                         isExpanded: _isOpen[0]),
//                                     ExpansionPanel(
//                                         headerBuilder: (context, isOpen) {
//                                           return Text("Filter2");
//                                         },
//                                         body: Text("THERE"),
//                                         isExpanded: _isOpen[1]),
//                                     ExpansionPanel(
//                                         headerBuilder: (context, isOpen) {
//                                           return Text("Filter3");
//                                         },
//                                         body: Text("EVERYWHERE"),
//                                         isExpanded: _isOpen[2]),
//                                   ],
//                                   expansionCallback: (int i, bool isOpen) =>
//                                       setState(() {
//                                         _isOpen[i] = !_isOpen[i];
//                                       }))