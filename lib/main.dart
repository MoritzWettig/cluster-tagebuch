import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'src/routes.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('de', 'DE'),
      ],
      initialRoute: '/homescreen',
      routes: routes,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.white, backgroundColor: Colors.teal),
        scaffoldBackgroundColor: Colors.grey[200],
        brightness: Brightness.light,
        canvasColor: Colors.grey[300].withAlpha(0),
        textSelectionColor: Colors.grey[350],
        cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: Colors.white,
        ),
        splashColor: Colors.teal,
        primarySwatch: Colors.teal,
        cursorColor: Colors.white,
        dividerColor: Colors.transparent,
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.black.withAlpha(0)),
      ),
      darkTheme: ThemeData(
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.white, backgroundColor: Colors.teal),
        scaffoldBackgroundColor: Colors.grey[850],
        brightness: Brightness.dark,
        backgroundColor: Colors.grey[850],
        primarySwatch: Colors.teal,
        splashColor: Colors.teal,
        canvasColor: Colors.grey[300].withAlpha(0),
        cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: Colors.white,
        ),
        primaryColor: Colors.teal,
        cursorColor: Colors.white,
        dividerColor: Colors.transparent,
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.black.withAlpha(0)),
      ),
    );
  }
}
