import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

String streamStr = "";
String roomCode = "";
String errMsg = "";
ValueNotifier<int> responseNum = ValueNotifier(0);
var host = false;
var user = false;
var currQ = 0;
List<PollObj> questions = [];
ValueNotifier<List<int>> responses = ValueNotifier([0, 0, 0, 0]);
ValueNotifier<String> serverQ = ValueNotifier("");
final channel = WebSocketChannel.connect(
  Uri.parse("wss://robopoll-server.herokuapp.com"),
);

StreamSubscription wsStream = channel.stream.listen((message) {
  streamStr = message;
  if (streamStr.contains('userAnswered')) {
    var regex = RegExp(r'total=(.*)').firstMatch(streamStr)!.group(1);
    responseNum.value = int.parse(regex!);
  } else if (streamStr.contains('initStatus')) {
    if (!streamStr.contains('error')) {
      if (streamStr.contains('code')) {
        roomCode =
            RegExp(r'code=(.*)').firstMatch(streamStr)!.group(1) as String;
        host = true;
      } else {
        user = true;
      }
    } else {
      if (streamStr.contains("codeNotFound")) {
        errMsg = "The code submitted doesn't exist.";
      } else if (streamStr.contains("alreadyInGame")) {
        errMsg = "You are already in a poll!";
      } else if (streamStr.contains("gameAlreadyStarted")) {
        errMsg = "The poll has already started.";
      } else {
        errMsg = "idek what happened";
      }
    }
  } else if (streamStr.contains('startStatus')) {
    currQ = 0;
  } else if (streamStr.contains('answerStatus')) {
    responses.value = (jsonDecode(RegExp(r'results=(.*)')
            .firstMatch(streamStr)!
            .group(1) as String) as List)
        .map((i) => int.parse(i.toString()))
        .toList();
  } else if (streamStr.contains('userAnswered')) {
    responseNum.value = int.parse(
        RegExp(r'total=(.*)').firstMatch(streamStr)!.group(1) as String);
  } else if (streamStr.contains('newQuestion')) {
    //serverQ.value = streamStr;
  } else if (streamStr.contains('goodbye')) {
    //serverQ.value = "";
  }
  print(streamStr);
  streamStr = "";
});

void main() {
  wsStream.resume();
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
  var goToHome = MaterialPageRoute(builder: (context) => const Homepage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {
            channel.sink.add('leaveGame?code=$roomCode'),
            Navigator.push(context, goToHome)
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: serverQ,
              builder: (context, value, _) {
                if (value.isNotEmpty && value.contains("newQuestion")) {
                  var question = jsonDecode(RegExp(r'question=(.*)')
                      .firstMatch(value)!
                      .group(1) as String);
                  return Column(
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
                              onPressed: () => _answerSubmit("0"),
                              child: Text(question.options[0]),
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
                              onPressed: () => _answerSubmit("1"),
                              child: Text(question.options[1]),
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
                                      fontSize: 150,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => _answerSubmit("2"),
                                child: Text(question.options[2]),
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
                                      fontSize: 150,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => _answerSubmit("3"),
                                child: Text(question.options[3]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Text(
                    'Waiting for host to start the poll',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
              },
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
  //resultsVisible is what determines what widgets are shown
  //and it changes when the host presses showResults
  var resultsVisible = false;
  var goToHome = MaterialPageRoute(builder: (context) => const Homepage());
  void resultsVis(var status) {
    if (status) {
      channel.sink.add('hostShowAnswers?code=$roomCode');
    } else {
      channel.sink.add('hostNextQuestion?code=$roomCode');
      if (currQ + 1 == questions.length) {
        Navigator.push(
          context,
          goToHome,
        );
      }
    }
    setState(
      () {
        resultsVisible = !resultsVisible;
        if (!status && currQ + 1 < questions.length) {
          currQ++;
        }
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
          onPressed: () => {
            channel.sink.add('endGame?code=$roomCode'),
            Navigator.push(context, goToHome)
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(questions[currQ].question,
                style: const TextStyle(fontSize: 48)),
            Text(questions[currQ].options[0],
                style: const TextStyle(fontSize: 24, color: Colors.red)),
            Text(questions[currQ].options[1],
                style: const TextStyle(fontSize: 24, color: Colors.blue)),
            Text(questions[currQ].options[2],
                style: const TextStyle(fontSize: 24, color: Colors.amber)),
            Text(questions[currQ].options[3],
                style: const TextStyle(fontSize: 24, color: Colors.green)),
            ValueListenableBuilder(
                valueListenable: responseNum,
                builder: ((context, value, child) {
                  return Text("$value responses",
                      style: const TextStyle(fontSize: 28));
                })),
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
                  onPressed: () => resultsVis(true),
                ),
              ),
            ),
            Visibility(
              visible: resultsVisible,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ValueListenableBuilder(
                    valueListenable: responses,
                    builder: ((context, value, child) {
                      return Column(
                        children: <Widget>[
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Text(
                                "${questions[currQ].options[0]}: ${responses.value[0]} responses",
                                style: const TextStyle(fontSize: 24),
                              )),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              "${questions[currQ].options[1]}: ${responses.value[1]} responses",
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              "${questions[currQ].options[2]}: ${responses.value[2]} responses",
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              "${questions[currQ].options[3]}: ${responses.value[3]} responses",
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  Container(
                    margin: const EdgeInsets.all(50),
                    child: ElevatedButton(
                      child: const Text("Next"),
                      onPressed: () => resultsVis(false),
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

  PollObj pollObject = PollObj(question: "", options: []);
  void submitData() {
    for (var widget in dynamicList) {
      pollObject = PollObj(question: "", options: []);
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
        questions.add(pollObject);
      }
    }
    if (questions.isEmpty) {
      _emptyQuestionsDialog(context);
    } else {
      for (var question in questions) {
        channel.sink.add(
            'hostSaveQuestion?code=$roomCode&question=${question.question}&options=${question.options[0]}&options=${question.options[1]}&options=${question.options[2]}&options=${question.options[3]}');
      }
      streamStr = "";
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
            onPressed: () => {
              channel.sink.add('hostStartGame?code=$roomCode'),
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GamePage(),
                ),
              )
            },
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
    void returnToHome() {
      channel.sink.add('endGame?code=$roomCode');
      host = false;
      Navigator.push(context, goToHome);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => returnToHome(),
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
    host = true;
    channel.sink.add("hostInit");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HostPage(),
      ),
    );
  }

  var _fieldVisible = true;

  Future<void> codeSubmit(var codeFieldCont) async {
    if (codeFieldCont.text.isNotEmpty) {
      roomCode = codeFieldCont.text;
      channel.sink.add('userInit?code=$roomCode');
      await Future.delayed(const Duration(seconds: 2));
      if (user) {
        // ignore: use_build_context_synchronously
        wsStream.pause();
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AnswerPage(),
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        _wrongCodeDialog(context);
      }
    } else {
      _wrongCodeDialog(context);
    }
  }

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
                            onEditingComplete: () => codeSubmit(codeFieldCont),
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
  channel.sink.add("userSubmitAnswer?code=$roomCode&answer=$choice");
  print("$choice sent to server");
}

void _wrongCodeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Umm...'),
        content: Text(errMsg),
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
