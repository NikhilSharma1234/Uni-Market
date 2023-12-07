import 'package:flutter/material.dart';
import 'navbar.dart';
import 'ItemGeneration/data.dart';
import '/ItemGeneration/AbstractItemFactory.dart';
import 'package:flutter/services.dart';

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
  late List<Widget> items;

  // redraws the items on the page based on search results
  redrawItems(List<Widget> newItems, bool append) {
    setState(() {
      append ? items = items + newItems : items = newItems;
    });
  }

  // called just after initstate, used to set the initial items displayed
  @override
  void didChangeDependencies() {
    items = generateFakeItems(30, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: NavBar(),
      // alternatively, this could all be chucked directly into the navbar or put on the side if it looks better
      body: Column(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
                padding: EdgeInsets.only(right: 60),
                child: Row(children: <Widget>[
                  Text("Filters Go here"),
                ])),
            SizedBox(
                width: .5 * screenWidth,
                child: MySearchBar(setPageState: redrawItems)),
          ],
        ),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: GridView.count(
                  crossAxisCount: 6,
                  children: items,
                  childAspectRatio: 2 / 3,
                )))
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
              ctrl.search(item, context).then((value) {
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
            ctrl.search(value, context).then((value) {
              widget.setPageState(value, false);
            });
            controller.closeView("");
          },
          viewOnChanged: (value) {
            updateSuggestions(value);
          },
          builder: (BuildContext context, SearchController controller) {
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
          suggestionsBuilder:
              (BuildContext context, SearchController controller) {
            return suggestions;
          }),
    );
  }
}

class PageController {
  AbstractItemFactory factory = AbstractItemFactory();
  ItemModel model = ItemModel();

  search(String value, BuildContext context) async {
    // do some search logic here r smthn
    return await generateItems(2, context);
  }

  generateItems(int num, BuildContext context) async {
    List<Widget> widgets = [];
    for (Data item in await model.getData('assets/items.csv', num)) {
      if (context.mounted) {
        widgets.add(factory.buildItemBox(item, context));
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
