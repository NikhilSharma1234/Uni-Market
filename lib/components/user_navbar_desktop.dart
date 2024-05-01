import 'package:flutter/material.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:uni_market/pages/profile.dart';
import 'package:uni_market/components/home_page/search_bar.dart';
import 'package:uni_market/pages/inbox_view.dart';
import 'package:uni_market/pages/wish_list.dart';
import 'package:uni_market/data_store.dart' as data_store;

class UserNavBarDesktop extends StatefulWidget implements PreferredSizeWidget {
  final Function(List<Widget>, bool) redrawItems;
  final Function(String) updateSearchText;
  final Filters filter;
  final bool mobile;

  const UserNavBarDesktop(
      {super.key,
      required this.redrawItems,
      required this.updateSearchText,
      required this.filter,
      required this.mobile});
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
      title: widget.mobile
          ? null
          : const Text('Uni-Market', style: TextStyle(fontSize: 20)),
      centerTitle: false,
      actions: <Widget>[
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: ItemSearchBar(
              setPageState: widget.redrawItems,
              updateSearchText: widget.updateSearchText,
              filter: widget.filter,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
              color: Colors.red,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      WishList(listOfItemIds: data_store.user.wishlist),
                ));
              },
              icon: const Icon(Icons.favorite)),
        ),
        !widget.mobile
            ? TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const InboxView(),
                    ),
                  );
                },
                //use a inbox icon
                child: const Icon(Icons.message_rounded),
              )
            : const SizedBox(width: 0, height: 0),
        !widget.mobile
            ? const MenuBar(children: <Widget>[
                SubmenuButton(
                  menuChildren: <Widget>[
                    SizedBox(width: 350, height: 525, child: ProfilePage())
                  ],
                  child: IconButton(
                    icon: Icon(Icons.person, size: 40),
                    onPressed: null,
                  ),
                )
              ])
            : const SizedBox(width: 0, height: 0),
      ],
    );
  }
}
