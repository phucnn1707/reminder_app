// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'hours.dart';
import 'minutes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  int _currentHourIndex = 0;
  int _currentMinuteIndex = 0;
  bool isSnoozeEnabled = true;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _hoursController = FixedExtentScrollController();
    _minutesController = FixedExtentScrollController();

    // Add listeners to track the selected item index
    _hoursController.addListener(() {
      setState(() {
        _currentHourIndex = _hoursController.selectedItem;
      });
    });

    _minutesController.addListener(() {
      setState(() {
        _currentMinuteIndex = _minutesController.selectedItem;
      });
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
                // Background for the focused row
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius:
                            BorderRadius.circular(12), // Add border radius here
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
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter text',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                  Divider(color: Colors.grey[700], thickness: 1),
                  ListTile(
                    title: Text("Repeat"),
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
                onPressed: () {
                  // Handle delete alarm
                },
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
