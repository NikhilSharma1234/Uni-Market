//inbox_view.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';
import 'package:uni_market/data_models/current_user.dart';
import 'inbox_controller.dart'; 
import 'package:uni_market/data_store.dart' as data_store;

class InboxView extends StatelessWidget {
  final InboxController _controller = InboxController();

  InboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve the current user's email from FirebaseAuth
    final CurrentUser currentUser = data_store.user;
    final String userEmail = currentUser.email;

    // Handle the case where there is no signed-in user.
    if (userEmail == "") {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Inbox'),
        ),
        body: const Center(
          child: Text(
            'Not signed in',
            style: TextStyle(fontSize: 24.0),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        automaticallyImplyLeading: kIsWeb ? true : false,
      ),
      bottomNavigationBar:
          !kIsWeb ? const UserNavBarMobile(activeIndex: 1) : null,
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
                  ),
                  const Divider(), // Adds a divider line below each ListTile
                ],
              );
            },
          );
        },
      ),
    );
  }
}
