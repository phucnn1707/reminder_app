// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:reminder_app/notification_helper.dart';
import 'package:workmanager/workmanager.dart';
import 'hours.dart';
import 'minutes.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  final TextEditingController _contentController = TextEditingController();
  bool isSnoozeEnabled = true;
  DateTime time = DateTime.now();
  late int _currentHourIndex;
  late int _currentMinuteIndex;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  // late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _currentHourIndex = time.hour;
    _currentMinuteIndex = time.minute;
    _hoursController =
        FixedExtentScrollController(initialItem: _currentHourIndex);
    _minutesController =
        FixedExtentScrollController(initialItem: _currentMinuteIndex);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // flutterTts = FlutterTts();

    _hoursController.addListener(() {
      setState(() {
        _currentHourIndex = _hoursController.selectedItem % 24;
        time = DateTime(
            time.year, time.month, time.day, _currentHourIndex, time.minute);
      });
    });

    _minutesController.addListener(() {
      setState(() {
        _currentMinuteIndex = _minutesController.selectedItem % 60;
        time = DateTime(
            time.year, time.month, time.day, time.hour, _currentMinuteIndex);
      });
    });
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Future<void> speak(String text) async {
  //   await flutterTts.setLanguage('en-US');
  //   await flutterTts.setPitch(1.0);
  //   await flutterTts.setSpeechRate(0.5);
  //   await flutterTts.speak(text);
  // }

  Future<void> _saveReminder() async {
    String content = _contentController.text;
    int hour = _currentHourIndex;
    int minute = _currentMinuteIndex;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter reminder content!'),
        backgroundColor: Color(0xFFFFC005),
      ));
      return;
    }

    DateTime scheduledTime =
        DateTime(time.year, time.month, time.day, hour, minute);

    if (scheduledTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('The scheduled time is not valid! Please choose again.'),
        backgroundColor: Color(0xFFFFC005),
      ));
      return;
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'reminder_notifications',
      'Channel for reminder_notifications',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      sound: 'notification.aiff',
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Reminder',
        content,
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);

    Duration duration = scheduledTime.difference(DateTime.now());
    Workmanager().registerOneOffTask(
      notificationId.toString(),
      "reminderTask",
      inputData: {'content': content},
      backoffPolicy: BackoffPolicy.exponential,
      initialDelay: duration,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Reminder set successfully!'),
      backgroundColor: Color(0xFF30D158),
    ));

    print('Reminder set for $hour:$minute with content: $content at $time');

    _contentController.clear();
    setState(() {
      time = DateTime.now();
      _hoursController.jumpToItem(time.hour);
      _minutesController.jumpToItem(time.minute);
      _currentHourIndex = time.hour;
      _currentMinuteIndex = time.minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
            child: Text(
              'Reminder App',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          backgroundColor: Color(0xFF1C1C1E)),
      backgroundColor: Color(0xFF1C1C1E),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // hours wheel
                      Container(
                        height: 300,
                        width: 60,
                        child: ListWheelScrollView.useDelegate(
                          controller: _hoursController,
                          squeeze: 1.9,
                          itemExtent: 50,
                          perspective: 0.003,
                          diameterRatio: 1,
                          overAndUnderCenterOpacity: .2,
                          physics: FixedExtentScrollPhysics(),
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: List<Widget>.generate(24, (index) {
                              return Container(
                                alignment: Alignment.center,
                                color: Colors.transparent,
                                child: MyHours(hours: index),
                              );
                            }),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 10,
                      ),

                      // minutes wheel
                      Container(
                        height: 300,
                        width: 60,
                        child: ListWheelScrollView.useDelegate(
                          controller: _minutesController,
                          squeeze: 1.9,
                          itemExtent: 50,
                          perspective: 0.003,
                          diameterRatio: 1,
                          overAndUnderCenterOpacity: .2,
                          physics: FixedExtentScrollPhysics(),
                          childDelegate: ListWheelChildLoopingListDelegate(
                            children: List<Widget>.generate(60, (index) {
                              return Container(
                                alignment: Alignment.center,
                                color: Colors.transparent,
                                child: MyMinutes(mins: index),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _contentController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF2C2C2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Enter text here',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                    // Divider(color: Colors.grey[700], thickness: 1),
                    // ListTile(
                    //   title: Text("Repeat daily"),
                    //   textColor: Colors.white,
                    //   trailing: Switch(
                    //     activeColor: Colors.white,
                    //     activeTrackColor: Colors.green,
                    //     inactiveThumbColor: Colors.white,
                    //     inactiveTrackColor: Colors.grey[600],
                    //     value: isSnoozeEnabled,
                    //     onChanged: (bool value) {
                    //       setState(() {
                    //         isSnoozeEnabled = value;
                    //       });
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 32, 18, 0),
              child: SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveReminder,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2C2C2E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(
                    "Set",
                    style: TextStyle(color: Color(0xFFEE443A), fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
