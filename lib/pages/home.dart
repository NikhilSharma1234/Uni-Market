import 'package:flutter/material.dart';
import 'package:uni_market/components/user_bottom_nav_bar.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_market/helpers/is_mobile.dart';
import 'package:uni_market/pages/posting_page.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';
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
    search(searchVal, 30, context, filter).then((value) {
      redrawItems(value, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    Widget body;

    if (kIsWeb) {
      // to make the smooth scroll work for web, I need a column of rows instead of a gridview. This is essentially doing the gridview calculations and putting it in the needed format.
      var itemSize = screenWidth / (screenWidth / 320).round();
      for (final (index, item) in items.indexed) {
        items[index] =
            (SizedBox(width: itemSize, height: itemSize, child: item));
      }
      int rowSize = (screenWidth / 320).round();
      int numRows = (items.length / rowSize).round();
      if (numRows == 0) {
        numRows = 1;
      }

      List<Widget> rows = [];
      int currentItem = 0;
      for (var row = 0; row < numRows; row++) {
        int endIndex = currentItem + rowSize;
        if (currentItem + rowSize > items.length) {
          endIndex = items.length;
        }
        rows.add(Row(children: items.sublist(currentItem, endIndex)));
        currentItem = endIndex;
      }
      body = WebSmoothScroll(
        controller: _scrollController,
        scrollOffset: 100,
        animationDuration: 400,
        // curve: Curves.easeInOutCirc,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _scrollController,
          child: Column(children: rows),
        ),
      );
    } else {
      body = GridView.count(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        crossAxisCount: (screenWidth / 320).round(),
        childAspectRatio: 2 / 2,
        children: items,
      );
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
            builder: (BuildContext context) => const Dialog(
                  insetPadding: EdgeInsets.all(0),
                  child: PostingPage(),
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
                            Text('-'),
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
