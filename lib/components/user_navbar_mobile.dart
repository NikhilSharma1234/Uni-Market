import 'package:flutter/material.dart';
import 'package:uni_market/pages/chat.dart';
import 'package:uni_market/pages/chat_selection_page.dart';
import 'package:uni_market/pages/profile.dart';
import 'package:uni_market/pages/home.dart';
import 'package:uni_market/pages/inbox_view.dart';

class UserNavBarMobile extends StatefulWidget implements PreferredSizeWidget {
  final int activeIndex;

  const UserNavBarMobile({super.key, required this.activeIndex});
  @override
  State<UserNavBarMobile> createState() => _UserNavBarMobileState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _UserNavBarMobileState extends State<UserNavBarMobile> {// Track which NavItem is currently hovered
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage()
              ),
            );
          },
          icon: Icon(
            Icons.storefront,
            size: 48,
            color: widget.activeIndex == 0 ? Colors.white : Colors.black
          )
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => InboxView()
              ),
            );
          },
          icon: Icon(
            Icons.send,
            size: 48,
            color: widget.activeIndex == 1 ? Colors.white : Colors.black
          )
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          },
          icon: Icon(
            Icons.person,
            size: 48,
            color: widget.activeIndex == 2 ? Colors.white : Colors.black
          )
        ),
      ],
    );
  }
}