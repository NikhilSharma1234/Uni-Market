import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserNavBar extends StatefulWidget implements PreferredSizeWidget {
  const UserNavBar({super.key});
  @override
  State<UserNavBar> createState() => _UserNavBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _UserNavBarState extends State<UserNavBar> {
  int hoveredIndex = -1; // Track which NavItem is currently hovered

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Uni-Market'),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            color: Colors.white,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF041E42),
                padding: const EdgeInsets.all(16.0),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Sign Out'),
            ),
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
      this.title, this.route, this.index, this.hoveredIndex, this.onHover,
      {super.key});

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
