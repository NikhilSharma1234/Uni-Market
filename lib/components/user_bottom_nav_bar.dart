import 'package:flutter/material.dart';
import 'package:uni_market/pages/profile.dart';
import 'package:uni_market/pages/home.dart';
import 'package:uni_market/pages/inbox_view.dart';

class UserBottomNavBar extends StatefulWidget implements PreferredSizeWidget {
  final int activeIndex;

  const UserBottomNavBar({super.key, required this.activeIndex});
  @override
  State<UserBottomNavBar> createState() => _UserBottomNavBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _UserBottomNavBarState extends State<UserBottomNavBar> {// Track which NavItem is currently hovered
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const InboxView()
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