import 'dart:io';
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
    switch (task) {
      case Workmanager.iOSBackgroundTask:
        print("The IOS background fetch was triggered");
        break;
    }
    bool success = true;
    return Future.value(success);

    // try {
    //   FlutterTts flutterTts = FlutterTts();

    //   await flutterTts.setSharedInstance(true);

    //   await flutterTts.setIosAudioCategory(
    //       IosTextToSpeechAudioCategory.ambient,
    //       [
    //         IosTextToSpeechAudioCategoryOptions.allowBluetooth,
    //         IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
    //         IosTextToSpeechAudioCategoryOptions.mixWithOthers
    //       ],
    //       IosTextToSpeechAudioMode.voicePrompt);

    //   Future<void> speak(String text) async {
    //     await flutterTts.setLanguage('ja-JP');
    //     await flutterTts.setPitch(1.0);
    //     await flutterTts.setSpeechRate(0.5);
    //     await flutterTts.awaitSpeakCompletion(true);
    //     await flutterTts.speak(text);
    //   }

    //   String content = inputData?['content'] ?? 'No content';
    //   await speak(content);

    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   await prefs.remove('content');
    //   await prefs.remove('time');
    //   await prefs.remove('notificationId');

    //   return Future.value(true);
    // } catch (e) {
    //   print('$e');
    //   return Future.value(false);
    // }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
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
