import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'inbox_controller.dart';
import 'package:uni_market/data_store.dart' as data_store;

class InboxView extends StatefulWidget {
  InboxView({Key? key}) : super(key: key);

  @override
  _InboxViewState createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  final InboxController _controller = InboxController();
  final Set<String> _selectedSessionIds = Set<String>();

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
    );
  }
}
