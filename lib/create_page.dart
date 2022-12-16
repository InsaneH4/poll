import 'package:web_socket_channel/web_socket_channel.dart';

import 'main.dart';
import 'host_page.dart';
import 'homepage.dart';
import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  final String title = "New Poll";

  @override
  State<CreatePage> createState() => _CreatePageState();
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
    questions = [];
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

class _CreatePageState extends State<CreatePage> {
  var showButton = true;
  List<DynamicWidget> dynamicList = [];
  PollObj pollObject = PollObj(question: "", options: []);

  void _emptyQuestionsDialog(BuildContext context, int type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Umm...'),
          content: Text(type == 0
              ? "You didn't add any questions"
              : "You have incomplete questions"),
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

  void submitData() {
    var found = false;
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
      } else {
        found = true;
        _emptyQuestionsDialog(context, 1);
      }
    }
    if (questions.isEmpty && !found) {
      _emptyQuestionsDialog(context, 0);
    } else {
      if (!found) {
        showButton = false;
      }
      for (var question in questions) {
        channel.sink.add(
            'hostSaveQuestion?code=$roomCode&question=${question.question}&options=${question.options[0]}&options=${question.options[1]}&options=${question.options[2]}&options=${question.options[3]}');
      }
      flushWsStream();
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
            onPressed: () {
              channel.sink.add('hostStartGame?code=$roomCode');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HostPage()),
              );
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
      reconnectWs();
      currQ = 0;
      questions.clear();
      responseNum.value = 0;
      responses.value = [0, 0, 0, 0];
      host = false;
      //Restart.restartApp();
      flushWsStream();
      Navigator.push(context, goToHome);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: returnToHome,
        ),
      ),
      body: Column(children: <Widget>[
        pollObject.question.isEmpty ? dynamicTextField : startGame,
        pollObject.question.isEmpty ? submitButton : Container(),
      ]),
      floatingActionButton: showButton
          ? FloatingActionButton(
              onPressed: _addDynamic,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void reconnectWs() {
    flushWsStream();
    setState(() {
      channel = WebSocketChannel.connect(endpoint);
      channel.stream.listen((message) => listenMethod(message));
    });
  }
}
