import 'package:charset_converter/charset_converter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class LottoQRData {
  final int round;
  final String drawDate;
  final List<int> winningNumbers;
  final int bonusNumber;
  final List<GameResult> games;

  LottoQRData({
    required this.round,
    required this.drawDate,
    required this.winningNumbers,
    required this.bonusNumber,
    required this.games,
  });

  @override
  String toString() {
    return '''
📦 제 $round회 ($drawDate)
당첨번호: $winningNumbers + [$bonusNumber]
${games.map((g) => g.toString()).join('\n')}
''';
  }
}

class GameResult {
  final String game;
  final List<int> numbers;
  final String result;

  GameResult({required this.game, required this.numbers, required this.result});

  @override
  String toString() {
    return '[$game] $numbers → $result';
  }
}

Future<LottoQRData?> crawlLottoQR(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) {
    print('❌ 요청 실패: ${response.statusCode}');
    return null;
  }

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
        ).stringMatch(header
            ?.querySelector('.key_clr1')
            ?.text ?? '') ??
            '',
      ) ??
          0;
  final drawDate = header
      ?.querySelector('.date')
      ?.text
      .trim() ?? '';

  // 2. 당첨번호 + 보너스
  final allBalls = doc.querySelectorAll('.winner_number .list .clr span');
  final winNums = allBalls.map((e) => int.parse(e.text.trim())).toList();
  final bonus = winNums.removeLast();

  // 3. 각 게임 (A, B, C)
  final rows = doc.querySelectorAll('.list_my_number table tbody tr');
  final games = <GameResult>[];

  for (var row in rows) {
    final game = row
        .querySelector('th')
        ?.text
        .trim() ?? '게임';
    final result = row
        .querySelector('.result')
        ?.text
        .trim() ?? '결과 없음';
    final numberSpans = row.querySelectorAll('td span.clr');
    final numbers = numberSpans.map((e) => int.parse(e.text.trim())).toList();

    games.add(GameResult(game: game, numbers: numbers, result: result));
  }

  return LottoQRData(
    round: round,
    drawDate: drawDate,
    winningNumbers: winNums,
    bonusNumber: bonus,
    games: games,
  );
}


