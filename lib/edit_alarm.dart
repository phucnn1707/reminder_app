import 'package:flutter/material.dart';
import 'dart:async';

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

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(widget.time)) {
        _timer.cancel();
        Navigator.pop(context, {'edit': false});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
              'Time: ${widget.time.hour}:${widget.time.minute}',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'edit': true,
                  'content': widget.content,
                  'time': widget.time,
                  'notificationId': widget.notificationId
                });
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
