import 'package:web_socket_channel/web_socket_channel.dart';
import 'main.dart';
import 'homepage.dart';
import 'package:flutter/material.dart';

class HostPage extends StatefulWidget {
  const HostPage({super.key});

  final String title = "Poll in progress";

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  var resultsVisible = false;
  var goToHome = MaterialPageRoute(builder: (context) => const Homepage());

  void resultsVis(var status) {
    if (status) {
      channel.sink.add('hostShowAnswers?code=$roomCode');
    } else {
      channel.sink.add('hostNextQuestion?code=$roomCode');
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
          onPressed: () {
            hostEndPoll();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(questions[currQ].question,
                style: Theme.of(context).textTheme.displayMedium),
            Visibility(
              visible: !resultsVisible,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(questions[currQ].options[0],
                        style:
                            const TextStyle(fontSize: 36, color: Colors.red)),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(questions[currQ].options[1],
                        style:
                            const TextStyle(fontSize: 36, color: Colors.blue)),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(questions[currQ].options[2],
                        style:
                            const TextStyle(fontSize: 36, color: Colors.amber)),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Text(questions[currQ].options[3],
                        style:
                            const TextStyle(fontSize: 36, color: Colors.green)),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
                valueListenable: responseNum,
                builder: ((context, value, child) {
                  return Text("$value total responses",
                      style: Theme.of(context).textTheme.displaySmall);
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
                                style: const TextStyle(
                                    fontSize: 36, color: Colors.red),
                              )),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              "${questions[currQ].options[1]}: ${responses.value[1]} responses",
                              style: const TextStyle(
                                  fontSize: 36, color: Colors.blue),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              "${questions[currQ].options[2]}: ${responses.value[2]} responses",
                              style: const TextStyle(
                                  fontSize: 36, color: Colors.amber),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              "${questions[currQ].options[3]}: ${responses.value[3]} responses",
                              style: const TextStyle(
                                  fontSize: 36, color: Colors.green),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  Container(
                    margin: const EdgeInsets.all(50),
                    child: ElevatedButton(
                      child: Text(
                          currQ + 1 == questions.length ? "End Poll" : "Next"),
                      onPressed: () {
                        if (currQ + 1 == questions.length) {
                          hostEndPoll();
                        } else {
                          resultsVis(false);
                          responseNum.value = 0;
                          responses.value = [0, 0, 0, 0];
                        }
                      },
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

  void reconnectWs() {
    flushWsStream();
    setState(() {
      channel = WebSocketChannel.connect(endpoint);
      channel.stream.listen((message) => listenMethod(message));
    });
  }

  void hostEndPoll() {
    channel.sink.add('endGame?code=$roomCode');
    reconnectWs();
    currQ = 0;
    responseNum.value = 0;
    responses.value = [0, 0, 0, 0];
    host = false;
    flushWsStream();
    Navigator.push(context, goToHome);
  }
}
