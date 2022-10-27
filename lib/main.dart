import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polling System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
              'Page in progress, user will answer questions from poll here',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  final String title = "Creating A New Poll";

  @override
  State<HostPage> createState() => _HostPageState();
}

class DynamicWidget extends StatelessWidget {
  DynamicWidget({super.key});

  final TextEditingController question = TextEditingController();
  final TextEditingController option1 = TextEditingController();
  final TextEditingController option2 = TextEditingController();
  final TextEditingController option3 = TextEditingController();
  final TextEditingController option4 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10), //haha

      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
                controller: question,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                )),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                  child: TextField(
                      controller: option1,
                      decoration: const InputDecoration(
                        labelText: 'Option 1',
                        border: OutlineInputBorder(),
                      )),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextField(
                      controller: option2,
                      decoration: const InputDecoration(
                        labelText: 'Option 2',
                        border: OutlineInputBorder(),
                      )),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextField(
                      controller: option3,
                      decoration: const InputDecoration(
                        labelText: 'Option 3',
                        border: OutlineInputBorder(),
                      )),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                  child: TextField(
                      controller: option4,
                      decoration: const InputDecoration(
                        labelText: 'Option 4',
                        border: OutlineInputBorder(),
                      )),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _HostPageState extends State<HostPage> {
  final goToHome = MaterialPageRoute(builder: (context) => const MyHomePage());
  var _showButton = true;
  List<DynamicWidget> dynamicList = [];
  List<String> questions = [];
  List<String> option1 = [];
  List<String> option2 = [];
  List<String> option3 = [];
  List<String> option4 = [];

  void _emptyQuestionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Umm...'),
          content: const Text("You didn't add any questions"),
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

  void _addDynamic() {
    if (questions.isNotEmpty) {
      questions = [];
      option1 = [];
      option2 = [];
      option3 = [];
      option4 = [];
      dynamicList = [];
    }
    setState(() {});
    dynamicList.add(DynamicWidget());
  }

  void submitData() {
    for (var widget in dynamicList) {
      questions.add(widget.question.text);
      option1.add(widget.option1.text);
      option2.add(widget.option2.text);
      option3.add(widget.option3.text);
      option4.add(widget.option4.text);
    }
    if (questions.isNotEmpty &&
        option1.isNotEmpty &&
        option2.isNotEmpty &&
        option3.isNotEmpty &&
        option4.isNotEmpty) {
      _showButton = false;
    } else {
      _emptyQuestionsDialog(context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget dynamicTextField = Flexible(
      flex: 2,
      child: ListView.builder(
        itemCount: dynamicList.length,
        itemBuilder: (_, index) => dynamicList[index],
      ),
    );
    Widget result = Flexible(
        flex: 1,
        child: Card(
          child: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      child: Text(
                          "#${index + 1}   ${questions[index]}: "
                          "${option1[index]}, ${option2[index]},"
                          " ${option3[index]}, ${option4[index]}",
                          style: const TextStyle(fontSize: 20)),
                    ),
                    const Divider()
                  ],
                ),
              );
            },
          ),
        ));
    Widget submitButton = Container(
      margin: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: submitData,
        child: const Text('Submit'),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => dynamicList.isNotEmpty
                ? _confirmQuitDialog(
                    context,
                    goToHome,
                  )
                : Navigator.push(context, goToHome)),
      ),
      body: Column(children: <Widget>[
        questions.isEmpty ? dynamicTextField : result,
        questions.isEmpty ? submitButton : Container(),
      ]),
      //TODO: add remove button by each question
      floatingActionButton: _showButton
          ? FloatingActionButton(
              onPressed: _addDynamic,
              child: const Icon(Icons.add),
            )
          : null,
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'Welcome to the polling system!',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(children: <Widget>[
              ElevatedButton(
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HostPage(),
                        ),
                      ),
                  child: const Text("Create Poll")),
              Container(
                margin: const EdgeInsets.only(top: 50),
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

  Future<void> _emptyFieldDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Umm...'),
          content: const Text("You didn't enter anything"),
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

Future<void> _confirmQuitDialog(BuildContext context, PageRoute route) {
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

Future<void> _tempDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('You did something!'),
        content: const Text('This feature is in development :)'),
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
