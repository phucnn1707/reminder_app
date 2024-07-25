import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:reminder_app/homepage.dart';
import 'package:workmanager/workmanager.dart';
import 'homepage.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
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

    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
