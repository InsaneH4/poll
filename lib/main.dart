import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polling System',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          fixedSize: (const Size(175, 50)),
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontSize: 24),
        )),
        primarySwatch: Colors.indigo,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = "Polling System";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class AnswerPage extends StatefulWidget {
  const AnswerPage({super.key, required this.title});

  final String title;

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  final goToHome = MaterialPageRoute(builder: (context) => const MyHomePage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _confirmQuitDialog(
            context,
            goToHome,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const <Widget>[
            Text(
              'Page still in progress, user will answer questions from poll here',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _confirmQuitDialog(BuildContext context, PageRoute route) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text('Are you sure you want to quit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, route),
              child: const Text('YES'),
            ),
          ],
        );
      },
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  void showField() {
    setState(() {
      _fieldVisible = !_fieldVisible;
    });
  }

  bool _fieldVisible = true;

  @override
  Widget build(BuildContext context) {
    final codeFieldCont = TextEditingController();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'Welcome to the polling system!',
              style: TextStyle(
                fontSize: 32,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(children: <Widget>[
              ElevatedButton(
                  onPressed: () => _tempDialog(context),
                  child: const Text("Create Poll")),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 275),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: const Offset(0.0, 0.0))
                        .animate(animation);
                    return ClipRect(
                        child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ));
                  },
                  child: _fieldVisible
                      ? ElevatedButton(
                          onPressed: showField, child: const Text("Join Poll"))
                      : SizedBox(
                          width: 175,
                          child: TextField(
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Join code',
                              ),
                              controller: codeFieldCont,
                              onEditingComplete: () {
                                if (codeFieldCont.text.isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const AnswerPage(
                                              title:
                                                  'temp (will get page title from name of poll)')));
                                } else {
                                  _emptyFieldDialog(context);
                                }
                                //^ Will get title from poll name
                              }),
                        ),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }

  Future<void> _tempDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('You did something!'),
          content: const Text('This feature is still in development :)'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _emptyFieldDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Umm...'),
          content: const Text("You didn't enter a code"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
