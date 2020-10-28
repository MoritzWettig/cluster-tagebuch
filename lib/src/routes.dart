import 'package:flutter/widgets.dart';

import 'ui/screens/about_app.dart';
import 'ui/screens/add_clusterscreen.dart';
import 'ui/screens/add_contactscreen.dart';
import 'ui/screens/delete_screen.dart';
import 'ui/screens/edit_clusterscreen.dart';
import 'ui/screens/edit_contactscreen.dart';
import 'ui/screens/homescreen.dart';
import 'ui/screens/notifications_screen.dart';
import 'ui/screens/qrscreen.dart';
import 'ui/screens/14days_report.dart';



final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/homescreen": (BuildContext context) => HomeScreen(),
  "/qrscreen": (BuildContext context) => QRScreen(),
  "/add_clusterscreen": (BuildContext context) => AddClusterScreen(),
  "/add_contactscreen": (BuildContext context) => AddContactScreen(),
  "/edit_clusterscreen": (BuildContext context) => EditClusterScreen(),
  "/edit_contactscreen": (BuildContext context) => EditContactScreen(),
  "/notification_screen": (BuildContext context) => NotificationScreen(),
  "/delete_screen": (BuildContext context) => DeleteScreen(),
  "/aboutapp_screen": (BuildContext context) => AboutAppScreen(),
  "/14daysreport_screen": (BuildContext context) => DaysReportScreen(),
};