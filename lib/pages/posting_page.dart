import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'package:uni_market/components/post_form.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';

class PostingPage extends StatefulWidget {
  const PostingPage({Key? key}) : super(key: key);

  @override
  State<PostingPage> createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
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
        appBar: kIsWeb ? const UserNavBarDesktop() : null,
        bottomNavigationBar: !kIsWeb ? const UserNavBarMobile() : null,
      resizeToAvoidBottomInset: false,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: widthScreen(screenWidth),
                    child: const PostForm(),
                  ),
                ],
              )
            ]));
  }
}
