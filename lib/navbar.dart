import 'package:flutter/material.dart';

// if you make this extend and return an AppBar widget, you can use it as the appBar: in other widgets
class NavBar extends AppBar {
  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

    double view_width = MediaQuery.of(context).size.width;
    double tab_size = view_width * 0.2;
    return AppBar(
      // backgroundColor: Colors.deepPurple,
      // leading is the image, displayed before the title and tabbar
      leadingWidth: 150,
      // not entirely sure why 80 is the right number to center the image, but here we are
      toolbarHeight: 80,

      leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
              padding: const EdgeInsets.all(8),
              // switches image based on dark mode
              child: Image.asset((darkModeOn)
                  ? "lib/images/logo_dark.png"
                  : "lib/images/logo_light.png"))),
      // title: const Text('Uni-Market'),
      flexibleSpace: Align(
          alignment: Alignment.topRight,
          child: TabBar(
            isScrollable: true,
            controller: TabController(length: 3, vsync: this),
            tabs: <Widget>[
              SizedBox(
                  width: tab_size,
                  child: const Tab(
                    text: 'Home',
                    icon: Icon(Icons.home),
                  )),
              SizedBox(
                  width: tab_size,
                  child: const Tab(
                    text: 'Search',
                    icon: Icon(Icons.search),
                  )),
              SizedBox(
                  width: tab_size,
                  child: const Tab(
                    text: 'Login',
                    icon: Icon(Icons.login),
                  )),
            ],
          )),
    );
  }
}
