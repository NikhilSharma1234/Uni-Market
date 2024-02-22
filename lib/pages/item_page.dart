import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/ItemPageInfo.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';
import 'package:uni_market/helpers/is_mobile.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'dart:ui';

class ItemPage extends StatefulWidget {
  final Item data;

  const ItemPage({Key? key, required this.data}) : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  int currentIndex = 0;
  late Item itemData;
  late List<String> productImages;
  late var sellerInformation;

  @override
  void initState() {
    super.initState();
    itemData = widget.data;
  }

  Future<String> loadImages() {
    return Future.delayed(const Duration(seconds: 1), () async {
      productImages = itemData.imagePath;
      await FirebaseFirestore.instance
              .collection('users')
              .doc(itemData.sellerId)
              .get()
              .then((value) => sellerInformation = value.data()
            );
    return 'asdads';
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Item Page')),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: !kIsWeb ? const UserNavBarMobile(activeIndex: 1) : null, // Custom app bar here
      body: FutureBuilder(
        future: loadImages(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget child;
          if (snapshot.hasData && isMobile(context)) {
            child =
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      width: screenWidth,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Column(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
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
                                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(i),
                                            fit: BoxFit.cover
                                          ),
                                        ),
                                        child: Stack(
                                          children: <Widget>[
                                            ClipRect(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                              child: Container(
                                                color: Colors.black.withOpacity(0.1),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Positioned(
                                            child: Image.network(i, fit: BoxFit.fitHeight),
                                            )
                                          )
                                          ]
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 10,
                            child: DotsIndicator(
                              dotsCount: itemData.imagePath.length,
                              position: currentIndex.toDouble()
                            ),
                          )   
                        ]
                      ),
                    ),
                    SizedBox(
                        width: screenWidth,
                        child: Expanded(
                          child: ItemPageInfo(itemData, sellerInformation)
                        )
                    ),
                  ],
                ),
              );
          } else if (snapshot.hasData && !isMobile(context)) {
            child =
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Expanded(
                              child: CarouselSlider(
                                options: CarouselOptions(
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
                                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(i),
                                            fit: BoxFit.cover
                                          ),
                                        ),
                                        child: Stack(
                                          children: <Widget>[
                                            ClipRect(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                              child: Container(
                                                color: Colors.black.withOpacity(0.1),
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Positioned(
                                            child: Image.network(i, fit: BoxFit.fitHeight),
                                            )
                                          )
                                          ]
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            )
                          ]
                        ),
                        Positioned(
                          bottom: 10,
                          child: DotsIndicator(
                            dotsCount: itemData.imagePath.length,
                            position: currentIndex.toDouble()
                          ),
                        )   
                      ]
                    ),
                  ),
                  SizedBox(
                      width: screenWidth * 0.3,
                      child: Expanded(
                        child: ItemPageInfo(itemData, sellerInformation)
                      )
                  ),
                ],
              );
          } else if (snapshot.hasError) {
            child = 
            Center(
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
            child = 
            const Center(
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
        }
      )
    );
  }
}