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
      body: const Center(
          child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              "About Us",
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text("Project Title: Uni-Market",
                  style: TextStyle(fontSize: 30))),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
                "Team 40: Jacob Hunter, Nikhil Sharma, Cameron McCoy, Yeamin Chowdhury",
                style: TextStyle(fontSize: 20)),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                  "Instructors: Sara Davis, Vihn Le, Dr. Dave Feil-Seifer, Devrin Lee, and Sara Davis",
                  style: TextStyle(fontSize: 20))),
          Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text("External Advisor: Dr. Eelke Folmer",
                  style: TextStyle(fontSize: 20))),
          Padding(
              padding: EdgeInsets.only(bottom: 20), child: Text("description")),
          Text("Project Resources: ")
        ],
      )),
    );
  }
}
