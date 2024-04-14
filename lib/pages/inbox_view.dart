import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uni_market/helpers/is_mobile.dart';
import 'inbox_controller.dart';
import 'package:uni_market/data_store.dart' as data_store;
import 'package:uni_market/components/user_bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:uni_market/image_data_store.dart';

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
    final userEmail = data_store.user.email;

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
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _showDeleteConfirmationDialog,
                )
              ]
            : [],
      ),
      body: StreamBuilder<List<ChatSessionSummary>>(
        stream: _controller.chatSummariesStream(userEmail),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.chat_bubble_outline,
                      size: 80, color: Colors.grey[300]),
                  Text(
                    'You have no messages yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }

          List<ChatSessionSummary> summaries = snapshot.data!;

          return ListView.builder(
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              var summary = summaries[index];
              String titleText = '${summary.buyerName} | ${summary.productName}';
              // Asynchronously fetch the image URL
              Future<String?> imageUrlFuture = ImageDataStore().getImageUrl(summary.productImageUrl);

              return FutureBuilder<String?>(
                future: imageUrlFuture,
                builder: (context, snapshot) {
                  Widget leadingWidget;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    leadingWidget = const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.image, color: Colors.white));
                  } else if (snapshot.hasData) {
                    leadingWidget = CircleAvatar(backgroundImage: NetworkImage(snapshot.data!));
                  } else {
                    leadingWidget = const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white));
                  }

                  return Column(
                    children: [
                      ListTile(
                        leading: leadingWidget, // Display the image or placeholder here
                        title: Text(titleText),
                        subtitle: Text(
                          '${summary.lastMessage}\n${DateFormat('dd/MM/yy hh:mm a').format(summary.lastMessageAt)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          _controller.onChatSelected(context, summary.sessionId, summary.productId, summary.sellerId);
                          setState(() {
                            _selectedSessionIds.clear();
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            if (_selectedSessionIds.contains(summary.sessionId)) {
                              _selectedSessionIds.remove(summary.sessionId);
                            } else {
                              _selectedSessionIds.add(summary.sessionId);
                            }
                          });
                        },
                        trailing: IconButton(
                          icon: Icon(
                            _selectedSessionIds.contains(summary.sessionId) ? Icons.check_circle : Icons.check_circle_outline,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_selectedSessionIds.contains(summary.sessionId)) {
                                _selectedSessionIds.remove(summary.sessionId);
                              } else {
                                _selectedSessionIds.add(summary.sessionId);
                              }
                            });
                          },
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar:
          isMobile(context) ? const UserBottomNavBar(activeIndex: 1) : null,
    );
  }

  void _showDeleteConfirmationDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          int count = _selectedSessionIds.length;
          return AlertDialog(
            title: const Text(
              'Delete Chat',
              style: TextStyle(color: Colors.red),
            ),
            content: Text('Are you sure you want to delete $count chat(s)?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  for (String sessionId in _selectedSessionIds) {
                    await _controller.markChatSessionAsDeleted(
                        sessionId, data_store.user.email);
                  }

                  setState(() {
                    _selectedSessionIds.clear();
                  });
                },
              ),
            ],
          );
        },
      );
    }
  }
}
