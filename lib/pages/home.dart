import 'package:flutter/material.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'ItemGeneration/data.dart';
import 'ItemGeneration/AbstractItemFactory.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';
import 'package:uni_market/pages/posting_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        resizeToAvoidBottomInset: false,
        appBar: kIsWeb ? UserNavBarDesktop(redrawItems: redrawItems) : null,
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
                                                  MaterialStatePropertyAll<
                                                      Color>(Colors.green),
                                            ),
                                            onPressed: () =>
                                                applyFilters(), // use this to call a function to update filters
                                            child: const Text('Apply Filters')))
                                  ])),
                        ),
                      ]),
                ))),
        // alternatively, this could all be chucked directly into the navbar or put on the side if it looks better
        body: body);
  }
}

class MySearchBar extends StatefulWidget {
  // passing a function from the parent down so we can use its setState to redraw the items
  final Function(List<Widget> newItems, bool append) setPageState;

  // final Filters filters;

  // requiring the function
  const MySearchBar({
    super.key,
    required this.setPageState,
    // required this.filters
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
  // initializing firebase access point
  final db = FirebaseFirestore.instance;
  final dbstorage = FirebaseStorage.instance.ref();

  // get the data from the text file
  getData(String fileName, int num) async {
    List<Data> items = [];

    final dbItems =
        await db.collection('items').where('condition', isEqualTo: 'NEW').get();

    for (var item in dbItems.docs) {
      var image = 'uh oh';
      try {
        image = await dbstorage
            .child(item.data()['images'][0].toString())
            .getDownloadURL();
      } catch (e) {
        print(e);
        image = 'missing image';
      }

      items.add(Data(item['name'], item['price'], item['dateListed'],
          item['sellerId'], image, item['tags']));
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
