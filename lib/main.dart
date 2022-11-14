//import 'package:ethan/cha.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

String streamStr = "";
final channel = WebSocketChannel.connect(
  Uri.parse("wss://robopoll-server.herokuapp.com"),
);
StreamSubscription wsStream = channel.stream.listen((message) {
  print(streamStr);
  streamStr = message;
});

void main() {
  wsStream.resume();
  channel.sink.add("test");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoboPoll',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            fixedSize: (const Size(175, 50)),
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontSize: 32),
          ),
        ),
        primarySwatch: Colors.indigo,
      ),
      home: const Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  final String title = "RoboPoll";

  @override
  State<Homepage> createState() => _HomepageState();
}

class AnswerPage extends StatefulWidget {
  const AnswerPage({super.key});

  final String title = "Joined Poll";

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  void pollStarted() {
    setState(
      () {
        _isPollStart = !_isPollStart;
      },
    );
  }

  var _isPollStart = false;
  var goToHome = MaterialPageRoute(builder: (context) => const Homepage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(context, goToHome),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              _isPollStart
                  ? 'Question from poll will be listed here'
                  : 'Waiting for host to start the poll',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Visibility(
                visible: !_isPollStart,
                child: ElevatedButton(
                  child: const Text("start poll"),
                  onPressed: () => pollStarted(),
                )),
            Visibility(
              visible: _isPollStart,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        width: 175,
                        height: 175,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(
                                fontSize: 150, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _answerSubmit("A"),
                          child: const Text("A"),
                        ),
                      ),
                      SizedBox(
                        width: 175,
                        height: 175,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            textStyle: const TextStyle(
                                fontSize: 150, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _answerSubmit("B"),
                          child: const Text("B"),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: 175,
                          height: 175,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.amber,
                              textStyle: const TextStyle(
                                  fontSize: 150, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _answerSubmit("C"),
                            child: const Text("C"),
                          ),
                        ),
                        SizedBox(
                          width: 175,
                          height: 175,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              textStyle: const TextStyle(
                                  fontSize: 150, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _answerSubmit("D"),
                            child: const Text("D"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  final String title = "Poll in progress";

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var resultsVisible = false;
  var responseNum = 0;
  var opt1num = 0, opt2num = 0, opt3num = 0, opt4num = 0;
  var goToHome = MaterialPageRoute(builder: (context) => const Homepage());

  void resultsVis() {
    setState(
      () {
        resultsVisible = !resultsVisible;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(context, goToHome),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text("Question will be here", style: TextStyle(fontSize: 48)),
            Text("$responseNum responses",
                style: const TextStyle(fontSize: 28)),
            Visibility(
              visible: !resultsVisible,
              child: SizedBox(
                width: 250,
                height: 75,
                child: ElevatedButton(
                  child: const Text(
                    "Show results",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => resultsVis(),
                ),
              ),
            ),
            Visibility(
              visible: resultsVisible,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Option 1: $opt1num responses",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Option 2: $opt2num responses",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Option 3: $opt3num responses",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Option 4: $opt4num responses",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(50),
                    child: ElevatedButton(
                      child: const Text("Next"),
                      onPressed: () => resultsVis(),
                    ),
                  ),
                ],
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

  final String title = "New Poll";

  @override
  State<HostPage> createState() => _HostPageState();
}

class PollObj {
  String question;
  List<String> options;

  PollObj({
    required this.question,
    required this.options,
  });
}

class DynamicWidget extends StatelessWidget {
  DynamicWidget({super.key});

  final TextEditingController question = TextEditingController();
  final TextEditingController choice1 = TextEditingController();
  final TextEditingController choice2 = TextEditingController();
  final TextEditingController choice3 = TextEditingController();
  final TextEditingController choice4 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10), //haha

      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: question,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextField(
                      controller: choice1,
                      decoration: const InputDecoration(
                        labelText: 'Answer',
                        border: OutlineInputBorder(),
                      )),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextField(
                    controller: choice2,
                    decoration: const InputDecoration(
                      labelText: 'Answer',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  controller: choice3,
                  decoration: const InputDecoration(
                    labelText: 'Answer',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  controller: choice4,
                  decoration: const InputDecoration(
                    labelText: 'Answer',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _HostPageState extends State<HostPage> {
  var _showButton = true;
  List<DynamicWidget> dynamicList = [];
  List<PollObj> questions = [];
  late PollObj pollObject = PollObj(question: "", options: []);

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
      dynamicList = [];
    }
    setState(() {});
    dynamicList.add(DynamicWidget());
  }

  String roomCode = "";

  void submitData() {
    roomCode = streamStr.substring(streamStr.indexOf("=") + 1);
    for (var widget in dynamicList) {
      if (widget.question.text.isNotEmpty &&
          widget.choice1.text.isNotEmpty &&
          widget.choice2.text.isNotEmpty &&
          widget.choice3.text.isNotEmpty &&
          widget.choice4.text.isNotEmpty) {
        pollObject.question = (widget.question.text);
        pollObject.options.add(widget.choice1.text);
        pollObject.options.add(widget.choice2.text);
        pollObject.options.add(widget.choice3.text);
        pollObject.options.add(widget.choice4.text);
      }
    }
    if (pollObject.question.isNotEmpty) {
      _showButton = false;
    } else {
      _emptyQuestionsDialog(context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget dynamicTextField = Flexible(
      child: ListView.builder(
        itemCount: dynamicList.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              child: const Center(
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.white, fontSize: 72),
                ),
              ),
            ),
            onDismissed: (direction) {
              setState(() => dynamicList.removeAt(index));
            },
            child: dynamicList[index],
          );
        },
      ),
    );
    Widget startGame = Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(25),
          child: const Text(
            "Room code:",
            style: TextStyle(fontSize: 42),
          ),
        ),
        Text(roomCode, style: const TextStyle(fontSize: 72)),
        Container(
          margin: const EdgeInsets.all(50),
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GamePage(),
              ),
            ),
            child: const Text("Start"),
          ),
        ),
      ],
    );

    Widget submitButton = Container(
      margin: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: submitData,
        child: const Text(
          'Submit',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
    var goToHome = MaterialPageRoute(builder: (context) => const Homepage());
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(context, goToHome),
        ),
      ),
      body: Column(children: <Widget>[
        pollObject.question.isEmpty ? dynamicTextField : startGame,
        pollObject.question.isEmpty ? submitButton : Container(),
      ]),
      floatingActionButton: _showButton
          ? FloatingActionButton(
              onPressed: _addDynamic,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _HomepageState extends State<Homepage> {
  void showField() {
    setState(
      () {
        _fieldVisible = !_fieldVisible;
      },
    );
  }

  void hostStart() {
    channel.sink.add("hostInit");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HostPage(),
      ),
    );
  }

  var _fieldVisible = true;

  @override
  Widget build(BuildContext context) {
    final codeFieldCont = TextEditingController();
    String code;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: const Text(
                'Welcome to RoboPoll!',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Column(children: <Widget>[
              SizedBox(
                width: 250,
                height: 75,
                child: ElevatedButton(
                    onPressed: () => hostStart(),
                    child: const Text("Create Poll",
                        style: TextStyle(fontSize: 36))),
              ),
              Container(
                margin: const EdgeInsets.only(top: 50),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 275),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0.0, 2.0),
                            end: const Offset(0.0, 0.0))
                        .animate(animation);
                    return ClipRect(
                        child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ));
                  },
                  child: _fieldVisible
                      //container makes animation work lol
                      // ignore: avoid_unnecessary_containers
                      ? Container(
                          child: SizedBox(
                            width: 250,
                            height: 75,
                            child: ElevatedButton(
                                onPressed: showField,
                                child: const Text("Join Poll",
                                    style: TextStyle(fontSize: 36))),
                          ),
                        )
                      : SizedBox(
                          width: 250,
                          height: 75,
                          child: TextField(
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 36),
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: 'Room Code',
                              hintStyle: TextStyle(fontSize: 36),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            autocorrect: false,
                            enableSuggestions: false,
                            controller: codeFieldCont,
                            onEditingComplete: () {
                              if (codeFieldCont.text.isNotEmpty) {
                                code = codeFieldCont.text;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AnswerPage(),
                                  ),
                                );
                              } else {
                                _wrongCodeDialog(context);
                              }
                              //^ Will get title from poll name
                            },
                          ),
                        ),
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}

void _answerSubmit(String choice) {
  if (choice == "A" || choice == "B" || choice == "C" || choice == "D") {
    channel.sink.add("User answered $choice"); //Sends data to websocket
    print("$choice sent to server");
  }
}

void _wrongCodeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Umm...'),
        content: const Text("You didn't enter a valid code"),
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

void _tempDialog(BuildContext context) {
  showDialog<void>(
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
