import 'package:flutter/material.dart';

// if you make this extend and return an AppBar widget, you can use it as the appBar: in other widgets
class NavBar extends AppBar {
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('TabBar Widget'),
      bottom: TabBar(
        controller: TabController(length: 3, vsync: this),
        tabs: const <Widget>[
          Tab(
            icon: Icon(Icons.cloud_outlined),
          ),
          Tab(
            icon: Icon(Icons.beach_access_sharp),
          ),
          Tab(
            icon: Icon(Icons.brightness_5_sharp),
          ),
        ],
      ),
    );
  }
}
