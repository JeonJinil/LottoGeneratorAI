import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotto_generator/model/LottoData.dart';
import 'package:lotto_generator/component/lotto_widget.dart';
import 'package:lotto_generator/screen/lotto/qr_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../component/crawling_lotto.dart';
import '../../constant/app_color.dart';

class LottoDetailScreen extends StatelessWidget {
  final QRResultData qrResultData;
  final LottoData lottoData;

  const LottoDetailScreen({
    super.key,
    required this.qrResultData,
    required this.lottoData,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> _handleQRScan() async {
      var status = await Permission.camera.status;
      if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
        status = await Permission.camera.request();
      }

      if (status.isGranted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const QRScannerPage()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('카메라 권한이 필요합니다.')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('구매복권 당첨결과', style: TextStyle(fontSize: 20)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (qrResultData != null) ...[
                      LottoTitle(round: lottoData.round, pickDate: lottoData.pickDate),
                      SizedBox(height: 10),
                      Ball(winningNumbers: lottoData.winningNumbers, bonus: lottoData.bonusNumber),
                      SizedBox(height: 10),
                      _PrintResult(
                        round: qrResultData.round,
                        winningNumbers: lottoData.winningNumbers,
                        bonusNumber: lottoData.bonusNumber,
                        games: qrResultData.grGames,
                      ),
                      SizedBox(height: 10),
                      _GamesTable(
                        lottoNumbers: lottoData.winningNumbers,
                        games: qrResultData.grGames,
                      ),
                    ] else
                      const Text("데이터를 불러올 수 없습니다."),

                  ],
                ),

              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(onPressed: _handleQRScan, child: Text('QR 다시 확인')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }


}

class _PrintBall extends StatelessWidget {
  final List<int> winningNumbers;
  final int bonus;

  const _PrintBall({required this.winningNumbers, required this.bonus});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2.0,
      children: [
        ...winningNumbers.map(
          (num) => CircleAvatar(
            backgroundColor: getBallColor(num),
            child: Text('$num', style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(
          width: 20,
          height: 40,
          child: Center(
            child: Text(
              '+',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        CircleAvatar(
          backgroundColor: getBallColor(bonus),
          child: Text('$bonus', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _PrintResult extends StatelessWidget {
  final int round;
  final List<int> winningNumbers;
  final int bonusNumber;
  final List<QRGame> games;

  const _PrintResult({
    super.key,
    required this.round,
    required this.winningNumbers,
    required this.bonusNumber,
    required this.games,
  });

  Future<String> getRank() async {
    List<int> wins = [0, 0, 0, 0, 0];
    int winCount = 0;
    String ret = "낙첨되었습니다.";

    // 이렇게 forEach 로 바꿔주세요
    games.forEach((g) {
      final matchCount = g.numbers.where(winningNumbers.contains).length;
      final hasBonus = g.numbers.contains(bonusNumber);

      // matchCount >= 3 인 경우만 winCount 올리기
      if (matchCount >= 3) {
        winCount++;
        if (matchCount == 6) {
          wins[0]++;
        } else if (matchCount == 5 && hasBonus) {
          wins[1]++;
        } else if (matchCount == 5) {
          wins[2]++;
        } else if (matchCount == 4) {
          wins[3]++;
        } else if (matchCount == 3) {
          wins[4]++;
        }
      }
    });

    print("wins: $wins");
    print("winCount: $winCount");

    if (winCount != 0) {
      int totalPrize = 0;
      final rankInfo = await fetchLottoRankDetails(round);
      print(rankInfo);
      for (int i = 0; i < wins.length; i++) {
        String digitsOnly = rankInfo[i].note.replaceAll(RegExp(r'[^0-9]'), '');
        // 정수로 파싱
        int prize = int.parse(digitsOnly);
        totalPrize += prize * wins[i];
      }
      ret = '총 당첨금액 ${NumberFormat('#,###').format(totalPrize)}원 입니다.';
    }

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getRank(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('에러: ${snapshot.error}');
        }
        final result = snapshot.data ?? '결과 없음';
        final isWin = result.contains('당첨');

        return Column(
          children: [
            Text(
              isWin ? "축하합니다!!" : "아쉽습니다.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isWin ? Colors.red : Colors.black,
              ),
            ),
            Text(
              result,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isWin ? Colors.red : Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GamesTable extends StatelessWidget {
  final List<int> lottoNumbers;
  final List<QRGame>? games;

  const _GamesTable({
    Key? key,
    required this.lottoNumbers,
    this.games,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final edgeInsets = const EdgeInsets.all(6);
    final radius = const Radius.circular(16);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(7),
      },
      border: TableBorder.symmetric(
        inside: BorderSide(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      children: [
        // 헤더
        TableRow(
          children: [
            Container(
              decoration: BoxDecoration(
                color: tableColor,
                borderRadius: BorderRadius.only(topLeft: radius),
              ),
              padding: edgeInsets,
              child: const Text(
                '게임',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: tableColor),
              padding: edgeInsets,
              child: const Text(
                '결과',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: tableColor,
                borderRadius: BorderRadius.only(topRight: radius),
              ),
              padding: edgeInsets,
              child: const Text(
                '번호',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // 데이터 행
        ...games?.asMap().entries.map((entry) {
          final i = entry.key;
          final g = entry.value;
          final isLast = i == games!.length - 1;

          return TableRow(
            children: [
              // 게임명 셀
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.only(
                    bottomLeft: isLast ? radius : Radius.zero,
                  ),
                ),
                padding: EdgeInsets.all(11),
                child: Text(
                  g.game,
                  textAlign: TextAlign.center,
                ),
              ),

              // 결과 셀
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                padding: EdgeInsets.all(11),
                child: Text(
                  g.result,
                  textAlign: TextAlign.center,
                ),
              ),

              // 번호 셀
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.only(
                    bottomRight: isLast ? radius : Radius.zero,
                  ),
                ),
                padding: edgeInsets,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  children: g.numbers.map((num) {
                    final isMatch = lottoNumbers.contains(num);
                    return CircleAvatar(
                      radius: 16,
                      backgroundColor:
                      isMatch ? getBallColor(num) : Colors.transparent,
                      child: Text(
                        '$num',
                        style: TextStyle(
                          color: isMatch ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }).toList() ?? [],
      ],
    );
  }
}
