import 'package:flutter/material.dart';
import 'navbar.dart';
import 'register.dart';
import 'verify.dart';
import 'aboutyou.dart';

// NOTE - to get assets like images to work, you need to run flutter build web then use the asset in code

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni-Market',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF041E42),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF041E42),
        fontFamily: 'Ubuntu',
        textTheme: const TextTheme().apply(bodyColor: Colors.white),
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  tapped(int step) {
    setState(() => index = step);
  }

  continued() {
    index < 2 ? setState(() => index += 1) : null;
  }

  cancel() {
    index > 0 ? setState(() => index -= 1) : null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // sets height of appbar
      appBar: PreferredSize(
          // width not working
          preferredSize: Size(screenWidth * 0.25, 110),
          child: NavBar()),
      body: Theme(
        data: ThemeData(
            hoverColor: Colors.transparent,
            shadowColor: Colors.transparent,
            canvasColor: const Color(0xFF041E42),
            colorScheme: const ColorScheme.dark(
                primary: Colors.white, secondary: Colors.white)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Expanded(flex: 3, child: Column()),
              Expanded(
                  flex: 4,
                  child: Column(children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'Welcome to the marketplace made for students.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ConstrainedBox(
                        constraints:
                            const BoxConstraints.tightFor(height: 400.0),
                        child: Stepper(
                          type: StepperType.horizontal,
                          currentStep: index,
                          onStepCancel: cancel,
                          onStepContinue: continued,
                          onStepTapped: (step) => tapped(step),
                          physics: const ScrollPhysics(),
                          steps: <Step>[
                            Register(index),
                            Verify(index),
                            AboutYou(index),
                          ],
                        ))
                  ])),
              const Expanded(flex: 3, child: Column())
            ],
          ),
        ),
      ),
    );
  }
}
