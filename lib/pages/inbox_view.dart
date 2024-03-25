import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart'; // Make sure this is pointing to the correct file path
import 'inbox_controller.dart';
import 'package:uni_market/data_store.dart' as data_store;
import '../components/user_navbar_mobile.dart'; // Adjust the path as necessary
import 'package:intl/intl.dart';

class InboxView extends StatefulWidget {
  InboxView({Key? key}) : super(key: key);

  @override
  _InboxViewState createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  final InboxController _controller = InboxController();
  final Set<String> _selectedSessionIds = Set<String>();

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

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
            : null, // Explicitly null for mobile or when not needed
        actions: _selectedSessionIds.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    print(_selectedSessionIds.toList());
                    setState(() {
                      _selectedSessionIds.clear();
                    });
                  },
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

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No chats found.');
          }

          List<ChatSessionSummary> summaries = snapshot.data!;

          return ListView.builder(
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              var summary = summaries[index];
              String titleText =
                  '${summary.buyerName} | ${summary.productName}';
              return Column(
                children: [
                  ListTile(
                    title: Text(titleText),
                    subtitle: Text(
                      '${summary.lastMessage}\n${DateFormat('dd/MM/yy hh:mm a').format(summary.lastMessageAt)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () =>
                        _controller.onChatSelected(context, summary.sessionId),
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
                        _selectedSessionIds.contains(summary.sessionId)
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
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
      ),
      bottomNavigationBar:
          !kIsWeb ? const UserNavBarMobile(activeIndex: 1) : null,
    );
  }
}
