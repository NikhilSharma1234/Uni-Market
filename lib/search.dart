import 'package:flutter/material.dart';
import 'navbar.dart'; // Import NavBar if needed
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'register.dart';
import 'package:flutter/services.dart';

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
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(screenWidth * 0.25, 110),
        child: NavBar(), // Include NavBar if needed
      ),
      // alternatively, this could all be chucked directly into the navbar or put on the side if it looks better
      body: Column(children: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(right: 60),
                child: Text("Filters Go here")),
            MySearchBar(),
          ],
        ),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: GridView.count(
                  crossAxisCount: 6,
                  children: generateItems(20, context),
                )))
      ]),
    );
  }
}

class MySearchBar extends StatefulWidget {
  const MySearchBar({super.key});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  bool isDark = true;
  late String searchVal;
  final SearchController controller = SearchController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SearchAnchor(
          searchController: controller,
          // viewOnSubmited and viewOnChanged added via this PR: https://github.com/flutter/flutter/pull/136840, allows us to grab submitted and changed values
          viewOnSubmitted: (value) {
            search(value, context);
            // closes the view and sets text to ""
            controller.closeView("");
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
            return List<ListTile>.generate(5, (int index) {
              final String item = 'item $index';
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(item);
                  });
                },
              );
            });
          }),
    );
  }
}

generateItems(int num, BuildContext context) {
  List items = <Widget>[];
  for (int i = 0; i < num; i++) {
    // temporary bit for testing
    items.add(Container(
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
        child: Center(
          child: Text(
            abstractItemFactory(getNextItem(), "Web", context),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        )));

    // this should return the preformatted widget and wont need above stuff
    // items.add(abstractItemFactory(getNextItem(), "Web", context));
  }
  // print(items);
  return items;
}

// placeholder for function that will generate the item tiles
abstractItemFactory(param, String str, BuildContext context) {
  return param;
}

// should get the next item from the database
getNextItem() {
  return "Item";
}

search(String value, context) {
  print(value);
  generateItems(2, context);
  // figure out how to redraw items page
  // SearchPage.setState();
}
