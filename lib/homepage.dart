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

  void hostStart() {
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

  Future<void> codeSubmit(var codeFieldCont) async {
    if (codeFieldCont.text.isNotEmpty) {
      roomCode = codeFieldCont.text;
      channel.sink.add('userInit?code=$roomCode');
      const loadBar = SnackBar(content: Text("Connecting..."));
      ScaffoldMessenger.of(context).showSnackBar(loadBar);
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

void _wrongCodeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
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
