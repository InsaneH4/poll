import 'homepage.dart';
import 'create_page.dart';
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
//TODO: notify user when poll starts
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
        errMsg = "Invalid code";
      } else if (streamStr.contains("alreadyInGame")) {
        errMsg = "You are already in a poll!";
      } else if (streamStr.contains("gameAlreadyStarted")) {
        errMsg = "The poll has already started.";
      } else {
        errMsg = "Something suspicious happened";
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
