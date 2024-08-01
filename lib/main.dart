import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:reminder_app/edit_alarm.dart';
import 'package:reminder_app/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      FlutterTts flutterTts = FlutterTts();

      Future<void> speak(String text) async {
        await flutterTts.setLanguage('en-US');
        await flutterTts.setPitch(1.0);
        await flutterTts.setSpeechRate(0.5);
        await flutterTts.awaitSpeakCompletion(
            true); // Ensure the function waits for speech completion
        await flutterTts.speak(text);
      }

      String content = inputData?['content'] ?? 'No content';
      await speak(content);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('content');
      await prefs.remove('time');
      await prefs.remove('notificationId');

      return Future.value(true);
    } catch (e) {
      print('$e');
      return Future.value(false);
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? content = prefs.getString('content');
  String? timeString = prefs.getString('time');
  int? notificationId = prefs.getInt('notificationId');

  if (content != null && timeString != null && notificationId != null) {
    DateTime time = DateTime.parse(timeString);
    runApp(MyApp(
      content: content,
      time: time,
      notificationId: notificationId,
    ));
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  final String? content;
  final DateTime? time;
  final int? notificationId;

  const MyApp({this.content, this.time, this.notificationId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: content != null && time != null && notificationId != null
          ? DisplayPage(
              content: content!,
              time: time!,
              notificationId: notificationId!,
            )
          : HomePage(),
    );
  }
}
