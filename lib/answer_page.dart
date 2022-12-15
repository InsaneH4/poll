import 'package:web_socket_channel/web_socket_channel.dart';

import 'main.dart';
import 'homepage.dart';
import 'package:flutter/material.dart';

var isStarted = false;
var goToHome = MaterialPageRoute(builder: (context) => const Homepage());

class AnswerPage extends StatefulWidget {
  const AnswerPage({super.key});

  final String title = "Joined Poll";

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => leavePollUsr(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: serverStream,
              builder: (context, value, _) {
                if (isStarted) {
                  var question = "Waiting for next question...";
                  if (value.contains("newQuestion")) {
                    question = RegExp(r':"(.*?)"').firstMatch(value)?.group(1)
                        as String;
                  }
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
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _answerSubmit("0"),
                              child: Text("Temp 1"),
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
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _answerSubmit("1"),
                              child: Text("temp 2"),
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
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => _answerSubmit("2"),
                                child: Text("Temp 3"),
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
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => _answerSubmit("3"),
                                child: Text("Temp 4"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: Text(
                            style: const TextStyle(fontSize: 48), question),
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

void _answerSubmit(String choice) {
  channel.sink.add("userSubmitAnswer?code=$roomCode&answer=$choice");
}

void userStart() {
  if (user) {
    isStarted = true;
  }
  flushWsStream();
}

void pollEnd(context) {
  flushWsStream();
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('The poll has ended'),
        actions: <Widget>[
          TextButton(
            onPressed: () => leavePollUsr(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void leavePollUsr(context) {
  user = false;
  isStarted = false;
  channel.sink.add('leaveGame?code=$roomCode');
  roomCode = "";
  flushWsStream();
  channel = WebSocketChannel.connect(
      Uri.parse("wss://robopoll-server.herokuapp.com"));
  //restart?
  Navigator.push(context, goToHome);
}
