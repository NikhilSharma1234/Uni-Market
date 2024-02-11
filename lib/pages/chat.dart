import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// This is where Jacob's item tile page will go
class _ChatPageState extends State<ChatPage> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: !kIsWeb ? UserNavBarMobile(activeIndex: 1) : null, // Custom app bar here
      body: Center(
        child: SizedBox(),
      ),
    );
  }
}