import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF2D2D33);
const Color redColor = Color(0xFFEA4955);
const Color blueColor = Color(0xFF549FBF);

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    fontFamily: 'GamjaFlower',
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Color(0xFFF875F5),
    textTheme: const TextTheme(
      labelLarge: TextStyle(  // navigation bar
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: blueColor,
      ),
    ),

  );

  // 필요하면 다크 테마도 추가 가능
  // static ThemeData get darkTheme => ThemeData.dark().copyWith(
  //   fontFamily: 'NotoSansKR',
  // );
}
