import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> InitializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart, isForegroundMode: true, autoStart: false));
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? content = prefs.getString('content');
  String? timeString = prefs.getString('time');
  int? notificationId = prefs.getInt('notificationId');

  // if (content == null) {
  //   content = 'No content provided';
  //   await prefs.setString('content', content);
  // }

  content ??= 'no content';
  timeString ??= 'mm-dd-yyyy :  09-02-2016';

  DateTime time = DateTime.parse(timeString);

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  await performTask(service, content, time);

  // Timer.periodic(const Duration(seconds: 5), (timer) async {
  //   if (service is AndroidServiceInstance) {
  //     if (await service.isForegroundService()) {
  //       print("foreground service is running with content: " + content!);

  //       service.setForegroundNotificationInfo(
  //           title: "SCRIPT ACADEMY", content: "sub my channel");
  //     }
  //   }
  //   print("background service is running with content: ");
  //   service.invoke('update');
  // });
}

performTask(ServiceInstance service, String content, DateTime time) async {
  Duration duration = time.difference(DateTime.now());

  await Future.delayed(duration);

  FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.awaitSpeakCompletion(
        true); // Ensure the function waits for speech completion
    await flutterTts.speak(text);
  }

  // String content = inputData?['content'] ?? 'No content';
  await speak(content);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('content');
  await prefs.remove('time');
  await prefs.remove('notificationId');

  print("foreground service is running with content: " + content!);

  service.stopSelf();
}
