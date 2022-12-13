import 'main.dart';
import 'homepage.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

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

void _answerSubmit(String choice) {
  channel.sink.add("userSubmitAnswer?code=$roomCode&answer=$choice");
  print("$choice sent to server");
}
