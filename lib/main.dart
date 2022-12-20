import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'homepage.dart';
import 'create_page.dart';
import 'answer_page.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

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
var isMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);
StreamSubscription wsStream =
    channel.stream.listen((message) => listenMethod(message));
//TODO: Publish on google play/app store
void main() {
  if (kIsWeb) {
    setUrlStrategy(null);
  }
  wsStream.resume();
  Timer.periodic(const Duration(seconds: 45), (timer) {
    channel.sink.add("ping");
  });
  runApp(const MyApp());
}

class GlobalContextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

const white = Colors.white;
const gold = Color(0xFFD4AF37);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      title: 'RoboPoll',
      navigatorKey: GlobalContextService.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.black,
          secondary: gold,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 72, fontWeight: FontWeight.bold, color: white),
          displayMedium: TextStyle(
              fontSize: 48, fontWeight: FontWeight.bold, color: white),
          displaySmall: TextStyle(fontSize: 36, color: white),
          headlineMedium: TextStyle(fontSize: 28, color: white),
          headlineSmall: TextStyle(fontSize: 24, color: white),
          titleLarge: TextStyle(fontSize: 18, color: white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            fixedSize: (const Size(175, 50)),
            backgroundColor: gold,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontSize: 36),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: gold),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: gold,
          cursorColor: white,
        ),
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
  if (kDebugMode) {
    print(streamStr);
  }
  if (streamStr.contains('userAnswered')) {
    var regex = RegExp(r'total=(.*)').firstMatch(streamStr)!.group(1);
    responseNum.value = int.parse(regex!);
  } else if (streamStr.contains('initStatus')) {
    if (!streamStr.contains('error')) {
      if (streamStr.contains('code')) {
        roomCode =
            RegExp(r'code=(.*)').firstMatch(streamStr)!.group(1) as String;
      } else if (streamStr.contains('initStatus?status=success')) {
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
  }
  flushWsStream();
}

void tempDialog(BuildContext context) {
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
