import 'dart:convert';

import 'package:charset_converter/charset_converter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class LottoRankInfo {
  final String rank;
  final String winnerCount;
  final String prizePerGame;
  final String note;

  LottoRankInfo({
    required this.rank,
    required this.winnerCount,
    required this.prizePerGame,
    required this.note,
  });

  @override
  String toString() {
    return '$rank | $winnerCount명 | $prizePerGame원 | $note';
  }
}

Future<List<LottoRankInfo>> fetchLottoRankDetails(int drawNumber) async {
  final url =
      'https://dhlottery.co.kr/gameResult.do?method=byWin&drwNo=$drawNumber';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedBody = await CharsetConverter.decode("euc-kr", response.bodyBytes);
      final document = parse(decodedBody);

      final List<LottoRankInfo> results = [];

      final rows = document.querySelectorAll('table.tbl_data tbody tr');
      for (final row in rows) {
        final cols = row.querySelectorAll('td');
        if (cols.length >= 4) {
          final rank = cols[0].text.trim();
          final winnerCount = cols[2].text.trim();      // 당첨게임 수
          final prizePerGame = cols[3].text.trim();     // 1게임당 당첨금
          final note = cols[3].text.trim();             // 비고 (자동/수동 등)

          results.add(
            LottoRankInfo(
              rank: rank,
              winnerCount: winnerCount,
              prizePerGame: prizePerGame,
              note: note,
            ),
          );
        }
      }

      return results;
    } else {
      print('페이지 불러오기 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('에러 발생: $e');
  }

  return [];
}

Future<int?> fetchLatestRound() async {
  final url = 'https://www.dhlottery.co.kr/gameResult.do?method=byWin';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final decodedBody = await CharsetConverter.decode("euc-kr", response.bodyBytes);
    final document = parse(decodedBody);

    // <h4><strong>1117</strong>회 당첨결과</h4>
    final h4 = document.querySelector('.win_result h4');
    if (h4 != null) {
      final strong = h4.querySelector('strong');
      if (strong != null) {
        final roundStr = strong.text.trim();
        String numericText = roundStr.replaceAll('회', '');  // '1234'
        int round = int.parse(numericText);
        return round;
      }
    }
  } else {
    print('❌ 요청 실패: ${response.statusCode}');
  }

  return null;
}

Future<Map<String, dynamic>> fetchLottoResult(int round) async {
  final url = Uri.parse('https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=$round');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('로또 데이터를 불러올 수 없습니다');
  }
}

