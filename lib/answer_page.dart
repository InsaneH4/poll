import 'package:web_socket_channel/web_socket_channel.dart';

import 'main.dart';
import 'homepage.dart';
import 'package:flutter/material.dart';

var isStarted = false;

class AnswerPage extends StatefulWidget {
  final String title = "Joined Poll";

  const AnswerPage({super.key});

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> {
  var waiting = 'Waiting for host to start the poll';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            leavePollUsr(context);
          },
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: pollOver,
        builder: (context, pollOverVal, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ValueListenableBuilder(
                  valueListenable: serverStream,
                  builder: (context, value, _) {
                    if (isStarted && !pollOverVal) {
                      var question = "Waiting for next question...";
                      if (value.contains("newQuestion")) {
                        question = RegExp(r':"(.*?)"')
                            .firstMatch(value)
                            ?.group(1) as String;
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
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
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
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
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
                    } else if (!isStarted) {
                      return Text(
                        waiting,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      );
                    } else if (pollOverVal) {
                      return Column(
                        children: <Widget>[
                          const Text(
                            "Poll has ended",
                            style: TextStyle(fontSize: 48),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 50),
                            child: ElevatedButton(
                              onPressed: () {
                                leavePollUsr(context);
                              },
                              child: const Text("Exit"),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Text(
                        'Something went wrong',
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
          );
        },
      ),
    );
  }

  void reconnectWs() {
    flushWsStream();
    setState(() {
      channel = WebSocketChannel.connect(endpoint);
      channel.stream.listen((message) => listenMethod(message));
    });
  }

  void leavePollUsr(context) {
    waiting = "";
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Homepage()));
    channel.sink.add('leaveGame?code=$roomCode');
    reconnectWs();
    user = false;
    isStarted = false;
    pollOver.value = false;
    roomCode = "";
    flushWsStream();
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
