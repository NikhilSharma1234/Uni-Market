import 'package:flutter/material.dart';
import 'navbar.dart'; // Import NavBar if needed
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'register.dart';

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
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Theme(
                data: ThemeData(
                  hoverColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  canvasColor: const Color(0xFF041E42),
                  colorScheme: const ColorScheme.dark(
                    primary: Colors.white,
                    secondary: Colors.white,
                  ),
                ),
                child: GridView.count(
                  crossAxisCount: 6,
                  children: generateItems(20, context),
                ))));
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
