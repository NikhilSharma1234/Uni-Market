import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uni_market/helpers/is_mobile.dart';
import 'inbox_controller.dart';
import 'package:uni_market/components/user_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class InboxView extends StatefulWidget {
  const InboxView({Key? key}) : super(key: key);

  @override
  InboxViewState createState() => InboxViewState();
}

class InboxViewState extends State<InboxView> {
  final InboxController _controller = InboxController();
  final Set<String> _selectedSessionIds = <String>{};

  @override
  Widget build(BuildContext context) {
    const userEmail = 'Current user\'s email';

    if (userEmail == "") {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Inbox'),
        ),
        body: const Center(
          child: Text('Not signed in', style: TextStyle(fontSize: 24.0)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        automaticallyImplyLeading: kIsWeb,
        leading: kIsWeb
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: _selectedSessionIds.isNotEmpty
            ? [
                const IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: null,
                )
              ]
            : [],
      ),
      body: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person,
                    color:
                        Colors.white)), // Display the image or placeholder here
            title: const Text('Headphones | Cameron McCoy'),
            subtitle: Text(
              '${'I\'ll see you there'}\n${DateFormat('MM/dd/yy hh:mm a').format(DateTime.now())}',
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              _controller.onChatSelected(
                  context, '1', '123', 'sellerEmail@nevada.unr.edu');
              setState(() {
                _selectedSessionIds.clear();
              });
            },
            trailing: IconButton(
              icon: Icon(
                _selectedSessionIds.contains('1')
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
              ),
              onPressed: () {
                setState(() {
                  if (_selectedSessionIds.contains('1')) {
                    _selectedSessionIds.remove('1');
                  } else {
                    _selectedSessionIds.add('1');
                  }
                });
              },
            ),
          ),
          const Divider(),
        ],
      ),
      bottomNavigationBar:
          isMobile(context) ? const UserBottomNavBar(activeIndex: 1) : null,
    );
  }
}
