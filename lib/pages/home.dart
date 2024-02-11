import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';
import 'package:uni_market/pages/posting_page.dart';
import 'ItemGeneration/data.dart';
import 'ItemGeneration/AbstractItemFactory.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:csv/csv.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> items = [const Text("")];

  // redraws the items on the page based on search results
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

  List<bool> _isOpen = [true, false, false];

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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: kIsWeb ? UserNavBarDesktop(redrawItems: redrawItems) : null,
      bottomNavigationBar: !kIsWeb ? const UserNavBarMobile(activeIndex: 0) : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => 
          showDialog<String>(
                context: context,
                builder: (BuildContext context) => 
                const Dialog(
                  insetPadding: EdgeInsets.all(0),
                  
                  child: PostingPage(),
                )
        ),
        child: const Icon(Icons.add),
      ),
      // alternatively, this could all be chucked directly into the navbar or put on the side if it looks better
      body: Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
        Expanded(
            flex: 1,
            child: Align(
                alignment: Alignment.center,
                child: ListView(children: [
                  ExpansionPanelList(
                      children: [
                        ExpansionPanel(
                            headerBuilder: (BuildContext context, bool isOpen) {
                              return Text("Filter1");
                            },
                            body: Text("HERE"),
                            isExpanded: _isOpen[0]),
                        ExpansionPanel(
                            headerBuilder: (context, isOpen) {
                              return Text("Filter2");
                            },
                            body: Text("THERE"),
                            isExpanded: _isOpen[1]),
                        ExpansionPanel(
                            headerBuilder: (context, isOpen) {
                              return Text("Filter3");
                            },
                            body: Text("EVERYWHERE"),
                            isExpanded: _isOpen[2]),
                      ],
                      expansionCallback: (int i, bool isOpen) => setState(() {
                            _isOpen[i] = !_isOpen[i];
                          }))
                ]))),
        Expanded(
            flex: 14,
            child: Column(children: <Widget>[
              !kIsWeb ? SizedBox(
                  width: .5 * screenWidth,
                  child: MySearchBar(setPageState: redrawItems)) : const SizedBox(),
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

  // requiring the function
  const MySearchBar({
    super.key,
    required this.setPageState,
  });

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
              // redraw the page when the search has been done
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
              constraints: const BoxConstraints(maxWidth: 500, minHeight: 45),
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
        const CsvToListConverter(eol: "\n",fieldDelimiter: ",").convert(rawFileString);

    for (var field in dataFile) {
      // do a certain number of lines
      if (numLines == 0) {
        break;
      }
      print(field);
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
