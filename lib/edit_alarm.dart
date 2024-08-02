import 'package:flutter/material.dart';
import 'package:reminder_app/homepage.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class DisplayPage extends StatefulWidget {
  final String content;
  final DateTime time;
  final int notificationId;

  DisplayPage(
      {required this.content,
      required this.time,
      required this.notificationId});

  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _saveData();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(widget.time)) {
        _timer.cancel();
        _clearData();
        if (Navigator.canPop(context)) {
          Navigator.pop(context, {
            'edit': false,
          });
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
      }
    });
  }

  // Method to save data using shared_preferences
  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('content', widget.content);
    await prefs.setString('time', widget.time.toIso8601String());
    await prefs.setInt('notificationId', widget.notificationId);
  }

  // Method to clear shared_preferences when editing
  void _clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('content');
    await prefs.remove('time');
    await prefs.remove('notificationId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hides the back button
        title: Center(
          child: Text(
            'Reminder Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        backgroundColor: Color(0xFF1C1C1E),
      ),
      backgroundColor: Color(0xFF1C1C1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Content: ${widget.content}',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Time: ${widget.time.hour.toString().padLeft(2, '0')}:${widget.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                _clearData(); // Clear data before editing
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, {
                    'edit': true,
                    'content': widget.content,
                    'time': widget.time,
                    'notificationId': widget.notificationId,
                  });
                } else {
                  _saveData();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C2C2E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text(
                "Edit",
                style: TextStyle(color: Color(0xFFEE443A), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
