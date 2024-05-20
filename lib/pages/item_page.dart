import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/item_page_info.dart';
import 'package:uni_market/helpers/is_mobile.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'dart:ui';
import 'dart:math';

class ItemPage extends StatefulWidget {
  final Item data;
  final bool noAction;

  const ItemPage({Key? key, required this.data, this.noAction = false})
      : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  int currentIndex = 0;
  late Item itemData;
  late List<String> productImages;
  String sellerName = 'Seller\'s Name';
  String sellerProfilePic = 'assets/portraits/nikhil.jpeg';
  int sellerItemsSold = Random().nextInt(10);
  int sellerItemsBought = Random().nextInt(10);

  @override
  void initState() {
    super.initState();
    itemData = widget.data;
  }

  Future<String> loadImages() {
    return Future.delayed(const Duration(seconds: 2), () {
      return 'hello';
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: const Text('Item Page')),
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
            future:
                loadImages(), // a previously-obtained Future<String> or null
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              Widget child;
              if (snapshot.hasData &&
                  (screenWidth < 875 || isMobile(context))) {
                child = SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: screenWidth,
                        child: Column(
                          children: [
                            CarouselSlider(
                              options: CarouselOptions(
                                height: MediaQuery.of(context).size.height,
                                enableInfiniteScroll: false,
                                viewportFraction: 1,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                },
                              ),
                              items: itemData.imagePath.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(i),
                                            fit: BoxFit.cover),
                                      ),
                                      child: Stack(children: <Widget>[
                                        ClipRect(
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 10.0, sigmaY: 10.0),
                                            child: Container(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                            child: Align(
                                          alignment: Alignment.center,
                                          child: Image.asset(i,
                                              fit: BoxFit.fitHeight),
                                        ))
                                      ]),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                            DotsIndicator(
                                dotsCount: itemData.imagePath.length,
                                position: currentIndex.toDouble()),
                          ],
                        ),
                      ),
                      SizedBox(
                          width: screenWidth,
                          child: ItemPageInfo(
                              itemData: itemData,
                              sellerName: sellerName,
                              sellerProfilePic: sellerProfilePic,
                              sellerItemsBought: sellerItemsBought,
                              sellerItemsSold: sellerItemsSold,
                              noAction: widget.noAction)),
                    ],
                  ),
                );
              } else if (snapshot.hasData && !isMobile(context)) {
                child = Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: screenWidth * 0.7,
                      child: Column(children: <Widget>[
                        CarouselSlider(
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.85,
                            enableInfiniteScroll: false,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                          ),
                          items: itemData.imagePath.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 1.0),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(i), fit: BoxFit.fill),
                                  ),
                                  child: Stack(children: <Widget>[
                                    Center(
                                      child: ClipRect(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 10.0, sigmaY: 10.0),
                                          child: Container(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                        child: Align(
                                      alignment: Alignment.center,
                                      child:
                                          Image.asset(i, fit: BoxFit.fitHeight),
                                    ))
                                  ]),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        DotsIndicator(
                            dotsCount: itemData.imagePath.length,
                            position: currentIndex.toDouble()),
                      ]),
                    ),
                    SizedBox(
                        width: screenWidth * 0.3,
                        child: ItemPageInfo(
                            itemData: itemData,
                            sellerName: sellerName,
                            sellerProfilePic: sellerProfilePic,
                            sellerItemsBought: sellerItemsBought,
                            sellerItemsSold: sellerItemsSold,
                            noAction: widget.noAction)),
                  ],
                );
              } else if (snapshot.hasError) {
                child = Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('Error: ${snapshot.error}'),
                      ),
                    ],
                  ),
                );
              } else {
                child = const Center(
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
              return child;
            }));
  }
}
