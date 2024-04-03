import 'package:flutter/material.dart';
import 'package:uni_market/components/post_form.dart';

class PostingPage extends StatefulWidget {
  final Function(List<Widget> newItems, bool append, [bool? start])
      setHomeState;
  const PostingPage({Key? key, required this.setHomeState}) : super(key: key);

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
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: widthScreen(screenWidth) * 0.95,
                      height: MediaQuery.of(context).size.height,
                      child: PostForm(
                        setHomeState: widget.setHomeState,
                      ),
                    ),
                  ],
                )
              ]),
        ));
  }
}
