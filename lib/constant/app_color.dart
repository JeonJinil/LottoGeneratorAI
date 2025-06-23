import 'package:flutter/material.dart';

final Color navigatorBarColor = Color(0xfd65d5cc);
final Color lottoCardColor = Color(0x65D5CCFD);

final Color lottoYellow = Colors.yellow[700]!;  // 1-10
final Color lottoBlue = Colors.blue[700]!;      // 11-20
final Color lottoRed = Colors.red[700]!;        // 21-30
final Color lottoBlack = Colors.black;          // 31-40
final Color lottoGreen = Colors.green[700]!;    // 41-45

Color getBallColor(int number) {
  if (number <= 10) return lottoYellow;
  if (number <= 20) return lottoBlue;
  if (number <= 30) return lottoRed;
  if (number <= 40) return lottoBlack;
  return lottoGreen;
}