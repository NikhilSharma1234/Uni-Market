import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_market/pages/home.dart';
import 'package:uni_market/pages/posting_page.dart';
import 'package:uni_market/pages/search.dart';

class UserNavBarDesktop extends StatefulWidget implements PreferredSizeWidget {
  const UserNavBarDesktop({super.key});
  @override
  State<UserNavBarDesktop> createState() => _UserNavBarDesktopState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _UserNavBarDesktopState extends State<UserNavBarDesktop> {
  int hoveredIndex = -1; // Track which NavItem is currently hovered

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Uni-Market'),
      automaticallyImplyLeading: false,
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const Home(),
              ),
            );
          },
          child: const Text('Home'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const SearchPage(
                  title: 'adsa',
                ),
              ),
            );
          },
          child: const Text('Search'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const PostingPage(),
              ),
            );
          },
          child: const Text('Create Post'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const Home(),
              ),
            );
          },
          child: const Text('Profile'),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
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
