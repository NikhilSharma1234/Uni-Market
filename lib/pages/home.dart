import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/components/ItemGeneration/item_box.dart';
import 'package:uni_market/components/home_page/drawer.dart';
import 'package:uni_market/components/user_bottom_nav_bar.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:uni_market/helpers/is_mobile.dart';
import 'package:uni_market/pages/posting_page.dart';
import 'package:uni_market/helpers/functions.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> items = [
    ItemBox(
        itemData: Item.fromJSON({
          'name': 'Sony XM1000',
          'id': '1',
          'description': 'Brand new headphones',
          'condition': 'NEW',
          'schoolId': 'UNR',
          'price': 149.99,
          'createdAt': 1112313,
          'images': [
            'assets/headphone1.webp',
            'assets/headphone2.jpg',
            'assets/headphone1.jpeg'
          ],
          'sellerId': 'selleremail@nevada.unr.edu',
          'tags': ['headphones', 'sound'],
          'isFlagged': false,
          'deletedAt': 0,
        }),
        context: context)
  ];
  String searchVal = "";
  int page = 1;
  bool loadingNewItems = false;
  final TextEditingController _tagsController = TextEditingController();
  static int maxTags = 6;
  final List<String?> _tags = [];
  List<String?> _suggestedTags = [
    "desk",
    "chair",
    "lamp",
    "bed",
    "rug",
    "phone",
  ];

  // Controllers
  late ScrollController _scrollController;
  @override
  void initState() {
    // initialize scroll controllers
    _scrollController = ScrollController();
    // searchTags("", maxTags, [])
    //     .then((value) => setState(() => _suggestedTags = value));

    super.initState();
  }

  List<Widget> tagSuggestionsBuilder(String input) {
    // update _suggestedTags with tags from typesense
    // leave selected tags in place as the first couple in _suggestedTags, give an x button for those to de-select them
    List<Widget> selected = List.generate(_tags.length, (int index) {
      final background = Theme.of(context).colorScheme.background;
      return Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          child: Container(
              decoration: BoxDecoration(
                  color: background == Colors.white
                      ? Colors.grey[200]
                      : Colors.black,
                  border: Border.all(
                      color: background == Colors.white
                          ? Colors.black
                          : Colors.white),
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              child: Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(_tags[index]!)),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          String? temp = _tags.removeAt(index);
                          _suggestedTags.add(temp);
                        });
                      },
                      icon: const Icon(Icons.close))
                ],
              )),
        ),
      );
    });

    List<Widget> suggested = List.generate(maxTags - _tags.length, (int index) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
            onTap: () => setState(() {
                  _tags.add(_suggestedTags[index]);
                  filter.tags = _tags;
                  _suggestedTags.removeAt(index);
                  _tagsController.clear();
                }),
            child: Container(
              decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.background == Colors.white
                          ? Colors.grey[200]
                          : Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 5, bottom: 5, left: 10, right: 10),
                  child: Text(_suggestedTags[index]!)),
            )),
      );
    });

    return selected + suggested;
  }

  setTags(List<String?> tags) {
    setState(() {
      _suggestedTags = tags;
    });
  }

  // redraws the items on the page based on search results
  redrawItems(List<Widget> newItems, bool append, [bool? start]) {
    setState(() {
      if (start ?? false) {
        items = newItems + items;
      } else {
        if (append) {
          items = items + newItems;
        } else {
          items = newItems;
        }
      }
    });
  }

  setCondition(Condition newCondition) {
    setState(() {
      filter.condition = newCondition;
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
  void applyFilters(Filters newFilter) {
    // search(searchVal, 30, context, newFilter).then((value) {
    //   redrawItems(value, false);
    // });
  }

  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    Widget body;

    Widget tagsWidget = Column(children: [
      const Tooltip(
        message: "Enter search for tags below and select tag by clicking it",
        child: Text("Tags",
            style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
      ),
      TextField(
        controller: _tagsController,
        onChanged: ((value) {
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 200), () {
            // searchTags(value, maxTags, _tags).then((value) {
            //   setTags(value);
            // });
          });
        }),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tagSuggestionsBuilder(_tagsController.text),
        ),
      )
    ]);

    body = Padding(
        padding: const EdgeInsets.all(1),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              page = 1;
              loadingNewItems = true;
            });
            clearFilters();
            // await search(searchVal, 30, context, filter, pageNum: page)
            //     .then((value) {
            //   redrawItems(value, false);
            // });
            setState(() {
              loadingNewItems = false;
            });
          },
          child: GridView.count(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              crossAxisCount: (screenWidth / 320).floor(),
              childAspectRatio: 20 / 23,
              children: items.length == 30 || page > 1
                  ? items +
                      [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            page > 1
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          page -= 1;
                                          loadingNewItems = true;
                                        });
                                        await search(
                                                searchVal, 30, context, filter,
                                                pageNum: page)
                                            .then((value) {
                                          redrawItems(value, false);
                                        });
                                        setState(() {
                                          loadingNewItems = false;
                                        });
                                      },
                                      child: const Text('Previous Page'),
                                    ),
                                  )
                                : const SizedBox(width: 0),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    page += 1;
                                    loadingNewItems = true;
                                  });
                                  await search(searchVal, 30, context, filter,
                                          pageNum: page)
                                      .then((value) {
                                    redrawItems(value, false);
                                  });
                                  setState(() {
                                    loadingNewItems = false;
                                  });
                                },
                                child: const Text('Next Page'),
                              ),
                            )
                          ],
                        )
                      ]
                  : items),
        ));

    if (loadingNewItems) {
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
    if (items.isEmpty && page > 1) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('No More Items'),
            Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      page -= 1;
                      loadingNewItems = true;
                    });
                    await search(searchVal, 30, context, filter, pageNum: page)
                        .then((value) {
                      redrawItems(value, false);
                    });
                    setState(() {
                      loadingNewItems = false;
                    });
                  },
                  child: const Text('Previous Page'),
                )),
          ],
        ),
      );
    } else if (items.isEmpty) {
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
              child: Text('Awaiting result or no items exist...'),
            ),
          ],
        ),
      );
    } else if (items.length == 1 && items[0] is Text) {
      body = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'No items found',
              style: TextStyle(fontSize: 32),
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
      drawer: getDrawer(context, lowerPrice, upperPrice, filter, applyFilters,
          setCondition, redrawItems, tagsWidget),
      body: body,
    );
  }
}
