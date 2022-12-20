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

  final codeFieldCont = TextEditingController();
  var fieldNotEmpty = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                  style: isMobile
                      ? Theme.of(context).textTheme.displaySmall
                      : Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                children: <Widget>[
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
                    child: SizedBox(
                      width: 250,
                      height: 75,
                      child: TextField(
                        keyboardAppearance: Brightness.dark,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall,
                        decoration: const InputDecoration(
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
                          hintText: 'Join Poll',
                          hintStyle:
                              TextStyle(fontSize: 36, color: Colors.grey),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        autocorrect: false,
                        enableSuggestions: false,
                        controller: codeFieldCont,
                        onChanged: (text) {
                          setState(() {
                            fieldNotEmpty = text.isNotEmpty && text.length == 4;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: AnimatedOpacity(
                      opacity: fieldNotEmpty ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: gold,
                          textStyle: Theme.of(context).textTheme.headlineMedium,
                        ),
                        onPressed: () => codeSubmit(codeFieldCont),
                        child: const Text("Submit"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _wrongCodeDialog(BuildContext context) {
    user = false;
    var disconnected = errMsg == "Not connected to server";
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
              onPressed: disconnected
                  ? () {
                      flushWsStream();
                      setState(() {
                        channel = WebSocketChannel.connect(endpoint);
                        channel.stream
                            .listen((message) => listenMethod(message));
                      });
                      Navigator.pop(context, 'OK');
                      //disconnected = false;
                    }
                  : () => Navigator.pop(context, 'OK'),
              child: Text(disconnected ? 'Reconnect' : 'OK'),
            ),
          ],
        );
      },
    );
  }
}
