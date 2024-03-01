import 'package:flutter/material.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';
import 'package:uni_market/components/search_bar.dart' as sb;
import 'package:uni_market/pages/posting_page.dart';

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
    sb.PageController ctrl = sb.PageController();
    ctrl.search(searchVal, 30, context, filter).then((value) {
      redrawItems(value, false);
    });
  }

  // called just after initstate, used to set the initial items displayed
  @override
  void didChangeDependencies() async {
    sb.PageController ctrl = sb.PageController();
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
      controller: ScrollController(),
      physics:
          const BouncingScrollPhysics(), // truing to make scrolling smooth not working
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
      drawer: Drawer(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: Align(
            alignment: Alignment.topLeft,
            child:
                ListView(shrinkWrap: true, padding: EdgeInsets.zero, children: [
              Padding(
                padding: const EdgeInsets.only(top: 55),
                child: Container(
                    color: Theme.of(context).colorScheme.background,
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
                                      value: Sort.newestToOldest,
                                      label: 'Newest to Oldest'),
                                  DropdownMenuEntry(
                                      value: Sort.oldestToNewest,
                                      label: 'Oldest to Newest'),
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
                          Padding(
                              padding: const EdgeInsets.all(5),
                              child: TextButton(
                                  style: const ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll<Color>(
                                            Colors.green),
                                  ),
                                  onPressed: () {
                                    applyFilters();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Apply Filters')))
                        ])),
              ),
            ]),
          )),
      body: body,
    );
  }
}
