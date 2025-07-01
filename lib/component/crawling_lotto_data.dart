import 'dart:convert';

import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:lotto_generator/model/LottoData.dart';

Future<LottoData> fetchLottoData(int round) async {
  final winUrl = Uri.parse(
    'https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=$round',
  );

  var response = await http.get(winUrl);
  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    var games = await fetchGameResult(round);
    var winLocations = await fetchWinLocation(round);

    LottoData ret = LottoData(
      round: jsonData['drwNo'],
      pickDate: DateTime.parse(jsonData['drwNoDate']),
      totalSell: jsonData['totSellamnt'],
      winningNumbers: List.generate(
        6,
        (index) => jsonData['drwtNo${index + 1}'],
      ),
      bonusNumber: jsonData['bnusNo'],
      games: games,
      winLocations: winLocations,
      countAutoWin: countAutoAndManual(winLocations),
    );
    return ret;
  } else {
    throw Exception('로또 데이터를 불러올 수 없습니다');
  }
}

Map<String, int> countAutoAndManual(List<WinLocation> winLocations) {
  final autoCount = winLocations.where((w) => w.isAuto).length;
  final manualCount = winLocations.length - autoCount;
  return {
    '자동': autoCount,
    '수동': manualCount,
  };
}

Future<List<GameResult>> fetchGameResult(int round) async {
  final url = Uri.parse(
    'https://dhlottery.co.kr/gameResult.do?method=byWin&drwNo=$round',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final decodedBody = await CharsetConverter.decode(
      "euc-kr",
      response.bodyBytes,
    );
    final document = parse(decodedBody);

    final List<GameResult> ret = [];

    final rows = document.querySelectorAll('table.tbl_data tbody tr');
    for (final row in rows) {
      final cols = row.querySelectorAll('td');
      if (cols.length >= 4) {
        final rank = cols[0].text.trim();
        final winnerCount = cols[2].text.trim(); // 당첨게임 수
        final prizePerGame = cols[3].text.trim(); // 1게임당 당첨금

        ret.add(
          GameResult(
            rank: rank,
            winnerCount: int.parse(
              winnerCount.replaceAll(RegExp(r'[^0-9]'), ''),
            ),
            prizePerGame: int.parse(
              prizePerGame.replaceAll(RegExp(r'[^0-9]'), ''),
            ),
          ),
        );
      }
    }

    return ret;
  } else {
    print('페이지 불러오기 실패: ${response.statusCode}');
  }

  return [];
}

Future<List<WinLocation>> fetchWinLocation(int round) async {
  final url = Uri.parse(
    'https://dhlottery.co.kr/store.do?method=topStore&pageGubun=L645&drwNo=$round',
  );
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('배출점 정보를 불러오는 데 실패했습니다 (status=${response.statusCode})');
  }

  // 데스크탑 페이지는 EUC-KR 인코딩이므로 반드시 디코딩
  final decoded = await CharsetConverter.decode('euc-kr', response.bodyBytes);
  final document = parse(decoded);

  // 데스크탑용 테이블 클래스
  final table = document.querySelector('table.tbl_data_col');
  if (table == null) {
    print('⚠️ fetchWinLocation: table.tbl_data_col 이 없습니다 (round=$round)');
    return [];
  }

  final rows = table.querySelectorAll('tbody tr');
  final locations = <WinLocation>[];

  for (final row in rows) {
    final cells = row.querySelectorAll('td');
    if (cells.length < 4) continue;

    final shopName = cells[1].text.trim();   // 상호명
    final address  = cells[3].text.trim();   // 주소
    final isAuto   = cells[2].text.trim().contains('자동');

    locations.add(WinLocation(
      shopName: shopName,
      address: address,
      isAuto: isAuto,
    ));
  }

  print('✅ fetchWinLocation($round) → ${locations[0].toString()}');
  return locations;
}

Future<QRResultData?> fetchQRData(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final decodedBody = await CharsetConverter.decode(
      "euc-kr",
      response.bodyBytes,
    );
    final doc = parser.parse(decodedBody);

    // 1. 회차와 날짜
    final header = doc.querySelector('.winner_number h3');
    final round =
        int.tryParse(
          RegExp(
                r'\d+',
              ).stringMatch(header?.querySelector('.key_clr1')?.text ?? '') ??
              '',
        ) ??
        0;

    // 2. 각 게임 (A, B, C, D, E)
    final rows = doc.querySelectorAll('.list_my_number table tbody tr');
    final games = <QRGame>[];

    for (var row in rows) {
      final game = row.querySelector('th')?.text.trim() ?? '게임';
      final result = row.querySelector('.result')?.text.trim() ?? '결과 없음';
      final numberSpans = row.querySelectorAll('td span.clr');
      final numbers = numberSpans.map((e) => int.parse(e.text.trim())).toList();

      games.add(QRGame(game: game, numbers: numbers, result: result));
    }

    return QRResultData(round: round, grGames: games);
  } else {
    print('❌ 요청 실패: ${response.statusCode}');
    return null;
  }
}

