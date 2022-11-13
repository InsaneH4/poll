//import 'package:ethan/cha.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final _channel = WebSocketChannel.connect(Uri.parse("ws://localhost:8080"));
final goToHome = MaterialPageRoute(builder: (context) => const Homepage());

void main() {
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
        )),
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

  final goToHome = MaterialPageRoute(builder: (context) => const Homepage());
  var _isPollStart = false;

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
  var responseNum = 0;

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
          children: <Widget>[
            const Text("Question will be here", style: TextStyle(fontSize: 48)),
            Text("$responseNum responses",
                style: const TextStyle(fontSize: 28)),
            SizedBox(
              width: 250,
              height: 75,
              child: ElevatedButton(
                child: const Text(
                  "Show results",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _tempDialog(context),
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
  List<String> questions;
  List<String> choice1;
  List<String> choice2;
  List<String> choice3;
  List<String> choice4;

  PollObj(
      {required this.questions,
      required this.choice1,
      required this.choice2,
      required this.choice3,
      required this.choice4});
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
  List<String> questions = [];
  List<String> choice1 = [];
  List<String> choice2 = [];
  List<String> choice3 = [];
  List<String> choice4 = [];
  late PollObj pollObj = PollObj(
    questions: questions,
    choice1: choice1,
    choice2: choice2,
    choice3: choice3,
    choice4: choice4,
  );

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
      pollObj.questions = [];
      pollObj.choice1 = [];
      pollObj.choice2 = [];
      pollObj.choice3 = [];
      pollObj.choice4 = [];
      dynamicList = [];
    }
    setState(() {});
    dynamicList.add(DynamicWidget());
  }

  void submitData() {
    for (var widget in dynamicList) {
      if (widget.question.text.isNotEmpty &&
          widget.choice1.text.isNotEmpty &&
          widget.choice2.text.isNotEmpty &&
          widget.choice3.text.isNotEmpty &&
          widget.choice4.text.isNotEmpty) {
        pollObj.questions.add(widget.question.text);
        pollObj.choice1.add(widget.choice1.text);
        pollObj.choice2.add(widget.choice2.text);
        pollObj.choice3.add(widget.choice3.text);
        pollObj.choice4.add(widget.choice4.text);
      }
    }
    if (questions.isNotEmpty &&
        choice1.isNotEmpty &&
        choice2.isNotEmpty &&
        choice3.isNotEmpty &&
        choice4.isNotEmpty) {
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
    //TODO: Make screen to show code and button to start game, get rid of display questions screen
    var roomCode = "will get from server";
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
        questions.isEmpty ? dynamicTextField : startGame,
        questions.isEmpty ? submitButton : Container(),
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
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HostPage(),
                          ),
                        ),
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
}

void _answerSubmit(String choice) {
  if (choice == "A" || choice == "B" || choice == "C" || choice == "D") {
    _channel.sink.add("User answered $choice"); //Sends data to websocket
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

void _confirmQuitDialog(BuildContext context, PageRoute route) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Hey!'),
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
