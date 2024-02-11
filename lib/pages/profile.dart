import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// This is where Jacob's item tile page will go
class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //  More defined screen width for applicable form UI
    widthScreen(double screenWidth) {
      if (screenWidth < 600) {
        return screenWidth * 0.95;
      }
      if (screenWidth < 800) {
        return screenWidth * 0.75;
      }
      if (screenWidth < 1200) {
        return screenWidth * 0.65;
      }
      return screenWidth * 0.45;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: kIsWeb ? const UserNavBarDesktop() : null,
      bottomNavigationBar: !kIsWeb ? const UserNavBarMobile(activeIndex: 2) : null, // Custom app bar here
      body: Center(
        child: SizedBox(
          width: screenWidth * 0.95,
          child: 
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shadowColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0))),
            onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            child: const Text('LOG OUT'),
          ),),
      ),
    );
  }
}