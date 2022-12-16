import 'homepage.dart';
import 'create_page.dart';
import 'answer_page.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

String streamStr = "";
String roomCode = "";
String errMsg = "Not connected to server";
ValueNotifier<int> responseNum = ValueNotifier(0);
ValueNotifier<bool> pollOver = ValueNotifier(false);
var host = false;
var user = false;
var currQ = 0;
List<PollObj> questions = [];
ValueNotifier<List<int>> responses = ValueNotifier([0, 0, 0, 0]);
ValueNotifier<String> serverStream = ValueNotifier("");
var endpoint = Uri.parse("wss://robopoll-server.herokuapp.com");
var channel = WebSocketChannel.connect(endpoint);
//TODO: fix host disconnecting, fix response num variables, fix options as button text for user
StreamSubscription wsStream =
    channel.stream.listen((message) => listenMethod(message));

void main() {
  wsStream.resume();
  runApp(const MyApp());
}

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoboPoll',
      navigatorKey: GlobalContextService.navigatorKey,
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

void flushWsStream() {
  streamStr = "";
}

void listenMethod(message) {
  streamStr = message;
  serverStream.value = streamStr;
  print(streamStr);
  if (streamStr.contains('userAnswered')) {
    var regex = RegExp(r'total=(.*)').firstMatch(streamStr)!.group(1);
    responseNum.value = int.parse(regex!);
  } else if (streamStr.contains('initStatus')) {
    if (!streamStr.contains('error')) {
      if (streamStr.contains('code')) {
        roomCode =
            RegExp(r'code=(.*)').firstMatch(streamStr)!.group(1) as String;
      } else if (streamStr.contains('status=success')) {
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
  } else if (streamStr.contains('gameStart')) {
    userStart();
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
  } else if (streamStr.contains('goodbye') && user) {
    pollOver.value = true;
    //leavePollUsr(GlobalContextService.navigatorKey.currentContext);
  }
  flushWsStream();
}
