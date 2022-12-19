import 'package:web_socket_channel/web_socket_channel.dart';

import 'main.dart';
import 'create_page.dart';
import 'answer_page.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  final String title = "RoboPoll";

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  void showField() {
    setState(
      () {
        _fieldVisible = !_fieldVisible;
      },
    );
  }

  void reconnectWs() {
    flushWsStream();
    setState(() {
      channel = WebSocketChannel.connect(endpoint);
      channel.stream.listen((message) => listenMethod(message));
    });
  }

  void hostStart() {
    reconnectWs();
    host = true;
    channel.sink.add("hostInit");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePage(),
      ),
    );
  }

  var _fieldVisible = true;

  void codeSubmit(var codeFieldCont) async {
    roomCode = codeFieldCont.text.toUpperCase();
    if (roomCode.isNotEmpty && roomCode.length == 4) {
      channel.sink.add('userInit?code=$roomCode');
      const loadBar = SnackBar(
        content: Text("Connecting..."),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(loadBar);
      await Future.delayed(const Duration(seconds: 2));
      if (user) {
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
      errMsg = "Invalid code";
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
              child: Text(
                'Welcome to RoboPoll!',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
            ),
            Column(children: <Widget>[
              SizedBox(
                width: 250,
                height: 75,
                child: ElevatedButton(
                  onPressed: () => hostStart(),
                  child: const Text(
                    "Create Poll",
                    style: TextStyle(fontSize: 36),
                  ),
                ),
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
                                  style: TextStyle(fontSize: 36)),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: 250,
                          height: 75,
                          child: TextField(
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: gold,
                                ),
                              ),
                              hintText: 'Room Code',
                              hintStyle:
                                  TextStyle(fontSize: 36, color: Colors.grey),
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

void _wrongCodeDialog(BuildContext context) {
  user = false;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text(
          'Error',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(errMsg, style: Theme.of(context).textTheme.titleLarge),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleLarge,
              foregroundColor: gold,
            ),
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
