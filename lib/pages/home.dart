import 'package:flutter/material.dart';
import 'package:uni_market/components/user_bottom_nav_bar.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:uni_market/helpers/is_mobile.dart';
import 'package:uni_market/pages/posting_page.dart';
import 'package:uni_market/data_store.dart' as data_store;
import 'package:uni_market/helpers/functions.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> items = data_store.itemBoxes;
  String searchVal = "";

  // Controllers
  late ScrollController _scrollController;

  @override
  void initState() {
    // initialize scroll controllers
    _scrollController = ScrollController();

    super.initState();
  }

  // redraws the items on the page based on search results
  redrawItems(List<Widget> newItems, bool append, [bool? start]) {
    setState(() {
      if (start ?? false) {
        // bad fix for loading thing at the end but I DO NOT CARE LITERALLY F OFF BRO
        items.removeLast();
        items = newItems + items;
      } else {
        append ? items = items + newItems : items = newItems;
      }
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
    search(searchVal, 30, context, filter).then((value) {
      redrawItems(value, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    int page = 1;
    bool endOfItems = false;

    double screenWidth = MediaQuery.of(context).size.width;

    Widget body;

    body = Padding(
        padding: const EdgeInsets.all(1),
        child: NotificationListener(
            onNotification: (notif) {
              if (notif is ScrollUpdateNotification && !endOfItems) {
                if (_scrollController.offset >
                    _scrollController.position.maxScrollExtent * 0.5) {
                  search(searchVal, 30, context, filter, pageNum: page += 1)
                      .then((value) {
                    if (value.isEmpty) {
                      endOfItems = true;
                    } else {
                      items.removeLast();
                      redrawItems(value, true);
                    }
                  });
                }
              }
              return true;
            },
            child: GridView.count(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                crossAxisCount: (screenWidth / 320).floor(),
                childAspectRatio: 20 / 23,
                children: items)));

    if (!endOfItems) {
      items.add(const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 16)),
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Awaiting result...'),
            ),
          ],
        ),
      ));
    } else {
      items.add(const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('End of Items'),
            ),
          ],
        ),
      ));
    }

    if (items.isEmpty) {
      body = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Awaiting result...'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: UserNavBarDesktop(
          redrawItems: redrawItems,
          updateSearchText: updateSearchText,
          filter: filter,
          mobile: isMobile(context)),
      bottomNavigationBar:
          isMobile(context) ? const UserBottomNavBar(activeIndex: 0) : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
                  insetPadding: const EdgeInsets.all(0),
                  child: PostingPage(
                    setHomeState: redrawItems,
                  ),
                )),
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8))),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 100, bottom: 100, left: 8, right: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Price Range",
                                style: TextStyle(fontSize: 24))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 125,
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
                              ),
                            ),
                            const Text('-'),
                            SizedBox(
                              width: 125,
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
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Sort By",
                                style: TextStyle(fontSize: 24))),
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
                                    value: Sort.newestToOldest,
                                    label: 'Newest to Oldest'),
                                DropdownMenuEntry(
                                    value: Sort.oldestToNewest,
                                    label: 'Oldest to Newest'),
                                DropdownMenuEntry(
                                    value: Sort.bestMatch, label: 'Best Match')
                              ]),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text("Condition",
                                style: TextStyle(fontSize: 24))),
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
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.all(5),
                        child: TextButton(
                            style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll<Color>(Colors.green),
                            ),
                            onPressed: () {
                              redrawItems([], false);
                              applyFilters();
                              Navigator.pop(context);
                            },
                            child: const Text('Apply Filters')))
                  ]),
            )),
      ),
      body: body,
    );
  }
}
