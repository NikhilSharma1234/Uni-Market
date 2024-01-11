import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/navbar.dart';
import 'package:uni_market/components/register.dart';
import 'package:uni_market/components/verify.dart';
import 'package:uni_market/components/about_you.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  final int? signUpStep;
  const MyHomePage({super.key, required this.title, required this.signUpStep});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
  bool returningUser = false;

  tapped(int step) {
    setState(() => index = step);
  }

  continued() {
    index < 2 ? setState(() => index += 1) : null;
  }

  cancel() {
    index > 0 ? setState(() => index -= 1) : null;
  }

  currentStep() {
    if (widget.signUpStep != null && !returningUser) {
      index = widget.signUpStep!;
      setState(() => returningUser = true);
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // sets height of appbar
      appBar: PreferredSize(
          // width not working
          preferredSize: Size(screenWidth * 0.25, 110),
          child: NavBar()),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                width:
                    screenWidth < 500 ? screenWidth * 0.95 : screenWidth * 0.45,
                child: Column(children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: AutoSizeText(
                      'Welcome to the marketplace made for students.',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w500,
                      ),
                      minFontSize: 16,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ConstrainedBox(
                      constraints:
                          BoxConstraints.tightFor(height: (screenHeight * 0.6)),
                      child: Stepper(
                        type: StepperType.horizontal,
                        currentStep: currentStep(),
                        controlsBuilder: (context, controller) {
                          return const SizedBox();
                        },
                        onStepCancel: cancel,
                        onStepContinue: continued,
                        onStepTapped: (step) => tapped(step),
                        physics: const ScrollPhysics(),
                        steps: <Step>[
                          register(index, () => tapped(1)),
                          verify(index, () => tapped(2)),
                          aboutYou(index),
                        ],
                      ))
                ])),
          ],
        ),
      ),
    );
  }
}
