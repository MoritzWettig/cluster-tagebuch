import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'homescreen.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isActiveDaily;
  String dailyNotficationTime;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;
  final dfnewh = new DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = new IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    isActiveDaily = false;
    getBoolDailyFromPref();
    getTimeDailyFromPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            icon: Icon(
              Icons.navigate_before,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text('Benachrichtungen'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.only(left: 10, top: 20, right: 10),
            elevation: 6,
            child: ListTile(
              leading: Icon(Icons.notifications_none, size: 34),
              title: Text('Täglich benachrichtigen'),
              subtitle: (isActiveDaily)
                  ? Text('Uhrzeit: $dailyNotficationTime')
                  : Text('Uhrzeit: deaktiviert'),
              trailing: Switch(
                value: isActiveDaily,
                onChanged: (value) async {
                  addBoolToPref('isActiveDaily', value);
                  setState(() {
                    isActiveDaily = value;
                  });
                  if (value) {
                    DateTime time = await _showTimePicker();
                    Time _time = Time(time.hour, time.minute, 0);
                    _dailyNotification(0, _time);
                    addIntToPref(
                        'dailyNotficationTime', time.millisecondsSinceEpoch);
                    getTimeDailyFromPref();
                  } else {
                    await flutterLocalNotificationsPlugin.cancel(0);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _dailyNotification(int id, Time time) async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '$id', 'Cluster Tagebuch', 'Fuege ein Cluster hinzu',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Cluster Tageguch');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
    // Um die täglichen Benachrichtungen zu einer bestimmten Uhrzeit zu ermöglichen, wird noch die Function showDailyAtTome verwendet
    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        id,
        'Cluster Tagebuch',
        'Erinnerung: Füge ein Cluster hinzu',
        time,
        platformChannelSpecifics);
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  _showTimePicker() async {
    final timepicker = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'Uhrzeit für Benachrichtungen',
        confirmText: 'Uhrzeit übernehmen',
        cancelText: 'Abbrechen');
    if (timepicker != null) {
      DateTime time = DateTime(0, 0, 0, timepicker.hour, timepicker.minute);
      return time;
    } else {
      var currenttime = DateTime.now();
      return currenttime;
    }
  }

  addBoolToPref(String prefkey, bool prefvalue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(prefkey, prefvalue);
  }

  addIntToPref(String prefkey, int prefvalue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(prefkey, prefvalue);
  }

  Future<Null> getBoolDailyFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isActiveDaily = prefs.getBool('isActiveDaily') ?? false;
    setState(() {
      isActiveDaily = isActiveDaily;
    });
  }

  Future<Null> getTimeDailyFromPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int dailyNotficationDateTime = prefs.getInt('dailyNotficationTime') ?? 0;
    dailyNotficationTime = dfnewh
        .format(DateTime.fromMillisecondsSinceEpoch(dailyNotficationDateTime));
    setState(
      () {
        dailyNotficationTime = dailyNotficationTime;
      },
    );
  }
}
