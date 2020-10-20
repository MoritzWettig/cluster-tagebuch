import 'dart:convert';
import 'dart:math';

/*
Erstellt einen Zufallsgenerierten Base64-String.
Dieser String wird zur Verschlüsselung der Datenbank verwendet.
Verwendet wird die Class im File sqflite_service.dart
Credits to: https://www.scottbrady91.com/Dart/Generating-a-Crypto-Random-String-in-Dart
*/



class GenerateRandomString {
  generate(int length) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64.encode(values);
  }
}
