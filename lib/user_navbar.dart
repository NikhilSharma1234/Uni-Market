import 'package:flutter/material.dart';

class UserNavBar extends StatefulWidget implements PreferredSizeWidget {
  const UserNavBar({super.key});
  @override
  State<UserNavBar> createState() => _UserNavBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _UserNavBarState extends State<UserNavBar> {
  int hoveredIndex = -1; // Track which NavItem is currently hovered

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Uni-Market'),
      actions: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              NavItem('Home', '/home', 0, hoveredIndex, (int index) {
                setState(() {
                  hoveredIndex = index;
                });
              }),
              NavItem('Profile', '/profile', 1, hoveredIndex, (int index) {
                setState(() {
                  hoveredIndex = index;
                });
              }),
              NavItem('Settings', '/settings', 2, hoveredIndex, (int index) {
                setState(() {
                  hoveredIndex = index;
                });
              }),
              NavItem('Create Post', '/createPost', 3, hoveredIndex,
                  (int index) {
                setState(() {
                  hoveredIndex = index;
                });
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class NavItem extends StatelessWidget {
  final String title;
  final String route;
  final int index;
  final int hoveredIndex;
  final ValueChanged<int> onHover;

  const NavItem(
      this.title, this.route, this.index, this.hoveredIndex, this.onHover);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        onHover(index);
      },
      onExit: (_) {
        onHover(-1);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GestureDetector(
          onTap: () {
            // Navigate to the specified route
            Navigator.of(context).pushReplacementNamed(route);
          },
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              decoration: hoveredIndex == index
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
