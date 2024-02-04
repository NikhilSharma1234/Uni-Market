import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/navbar.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
      // sets height of appbar
      appBar: NavBar(),
      body: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
        ],
      ),
    );
  }
}
