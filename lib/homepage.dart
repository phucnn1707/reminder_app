// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:reminder_app/notification_helper.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
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

    _hoursController.addListener(() {
      setState(() {
        _currentHourIndex = _hoursController.selectedItem;
        time = DateTime(
            time.year, time.month, time.day, _currentHourIndex, time.minute);
      });
    });

    _minutesController.addListener(() {
      setState(() {
        _currentMinuteIndex = _minutesController.selectedItem;
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

  Future<void> _saveReminder() async {
    String content = _contentController.text;
    int hour = _currentHourIndex;
    int minute = _currentMinuteIndex;

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter reminder content'),
      ));
      return;
    }

    DateTime scheduledTime =
        DateTime(time.year, time.month, time.day, hour, minute);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Reminder Notifications',
      'Channel for reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(0, 'Reminder', content,
        tz.TZDateTime.from(scheduledTime, tz.local), platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);

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
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
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
                      height: 500,
                      width: 60,
                      child: ListWheelScrollView.useDelegate(
                        controller: _hoursController,
                        squeeze: 1,
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 0.6,
                        overAndUnderCenterOpacity: .2,
                        physics: FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 24,
                          builder: (context, index) {
                            return Container(
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: MyHours(
                                hours: index,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    // minutes wheel
                    Container(
                      height: 500,
                      width: 60,
                      child: ListWheelScrollView.useDelegate(
                        controller: _minutesController,
                        squeeze: 1,
                        itemExtent: 50,
                        perspective: 0.005,
                        diameterRatio: 0.6,
                        overAndUnderCenterOpacity: .2,
                        physics: FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 60,
                          builder: (context, index) {
                            return Container(
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: MyMinutes(
                                mins: index,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter text here',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                  Divider(color: Colors.grey[700], thickness: 1),
                  ListTile(
                    title: Text("Repeat daily"),
                    textColor: Colors.white,
                    trailing: Switch(
                      activeColor: Colors.white,
                      activeTrackColor: Colors.green,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[600],
                      value: isSnoozeEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          isSnoozeEnabled = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text(
                  "Set",
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
