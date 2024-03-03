import 'package:flutter/material.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:uni_market/pages/profile.dart';
import 'package:uni_market/components/search_bar.dart';
import 'package:uni_market/pages/inbox_view.dart';

class UserNavBarDesktop extends StatefulWidget implements PreferredSizeWidget {
  final Function(List<Widget>, bool) redrawItems;
  final Function(String) updateSearchText;
  final Filters filter;

  const UserNavBarDesktop(
      {super.key,
      required this.redrawItems,
      required this.updateSearchText,
      required this.filter});
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
      automaticallyImplyLeading: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text('Uni-Market', style: TextStyle(fontSize: 20))),
          Expanded(
              child: Center(
                  child: ItemSearchBar(
                      setPageState: widget.redrawItems,
                      updateSearchText: widget.updateSearchText,
                      filter: widget.filter))),
        ],
      ),
      centerTitle: true,
      leadingWidth: 200,
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => InboxView(),
              ),
            );
          },
          child: const Text('Chat'),
        ),
        const MenuBar(
          children: <Widget>[
            SubmenuButton(
              menuChildren: <Widget>[
                SizedBox(width: 300, height: 500,child: ProfilePage())
              ],
              child: IconButton(icon: Icon(Icons.person, size: 40), onPressed: null,),
            )]
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
