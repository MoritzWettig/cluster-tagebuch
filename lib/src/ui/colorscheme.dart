import 'package:flutter/material.dart';

extension CustomColorScheme on ColorScheme {
  Color get chipcolor =>
      brightness == Brightness.light ? Colors.teal[300] : Colors.teal[500];
  Color get circleAvatarBackgroundColor =>
      brightness == Brightness.light ? Colors.teal[400] : Colors.teal[500];
  Color get qrcodeforeground =>
      brightness == Brightness.light ? Colors.grey[850] : Colors.white;
}
