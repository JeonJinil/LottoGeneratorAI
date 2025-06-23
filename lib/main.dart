import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lotto_generator/screen/home_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lotto_generator/theme/app_theme.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Timer(Duration(seconds: 1), () {
    FlutterNativeSplash.remove();
  });
  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: 'MaruBuri',
        textTheme: TextTheme(
          labelLarge: TextStyle(
            color: Colors.red,
            fontSize: 10.0,
            fontFamily: 'MaruBuri',
          ),
        ),
      ),
      home: HomeScreen(),
    ),
  );
}
