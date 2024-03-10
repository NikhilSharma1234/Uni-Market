import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/components/navbar.dart';
import 'package:uni_market/components/register.dart';
import 'package:uni_market/components/verify.dart';
import 'package:uni_market/components/about_you.dart';

class SignUpPage extends StatefulWidget {
  final String title;
  final int? signUpStep;
  const SignUpPage({super.key, required this.title, required this.signUpStep});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int index = 0;
  bool returningUser = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
    _focusNode.requestFocus();
  }

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
      // sets height of appbar
      appBar: NavBar(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SingleChildScrollView(
            child: SizedBox(
                width: widthScreen(screenWidth),
                child: Column(children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
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
                  SizedBox(
                      height: 450,
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
                          register(index, () => tapped(1), _focusNode),
                          verify(index, () => tapped(2)),
                          aboutYou(index),
                        ],
                      ))
                ])),
          ),
        ],
      ),
    );
  }
}
