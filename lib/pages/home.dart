import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

// This is where Jacob's item tile page will go
class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: kIsWeb ? UserNavBarDesktop() : null,
      bottomNavigationBar: !kIsWeb ? UserNavBarMobile() : null, // Custom app bar here
      body: Center(
        child: SizedBox(),
      ),
    );
  }
}