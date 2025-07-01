import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotto_generator/constant/app_color.dart';
import 'package:lotto_generator/model/LottoData.dart';
import 'crawling_lotto.dart';

class Lotto extends StatelessWidget {
  final LottoData lottoData;

  // final Map<String, dynamic>? lottoData;
  // final List<LottoRankInfo>? rankInfoList; //

  const Lotto({super.key, required this.lottoData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: primaryColor, width: 4.0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            LottoTitle(round: lottoData.round, pickDate: lottoData.pickDate),
            const SizedBox(height: 5),
            Ball(
              winningNumbers: lottoData.winningNumbers,
              bonus: lottoData.bonusNumber,
            ),
            const SizedBox(height: 5),
            _TotalSellmant(
              totalSellmant: lottoData.totalSell,
              countAutoWin: lottoData.countAutoWin,
            ),
            const SizedBox(height: 5),
            _RankTable(games: lottoData.games),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

class LottoTitle extends StatelessWidget {
  final int round;
  final DateTime pickDate;

  const LottoTitle({super.key, required this.round, required this.pickDate});

  @override
  Widget build(BuildContext context) {
    String onlyDate = pickDate.toString().split(' ')[0]; // 시간 지움
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$round회 ',
              style: TextStyle(
                color: Color(0xFF216AF3),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              '당첨번호',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        Text('($onlyDate일 추첨)', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class Ball extends StatelessWidget {
  final List<int> winningNumbers;
  final int bonus;

  const Ball({required this.winningNumbers, required this.bonus});

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

class _TotalSellmant extends StatelessWidget {
  final int totalSellmant;
  final Map<String, int> countAutoWin;

  const _TotalSellmant({
    super.key,
    required this.totalSellmant,
    required this.countAutoWin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '총 판매금액: ${NumberFormat('#,###').format(totalSellmant)}원 (자동: ${countAutoWin['자동']}, 수동: ${countAutoWin['수동']})',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}

class _RankTable extends StatelessWidget {
  final List<GameResult>? games;

  const _RankTable({super.key, this.games});

  @override
  Widget build(BuildContext context) {
    final EdgeInsets edgeInsets = EdgeInsets.all(6);
    final Radius radius = Radius.circular(16);
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(2.2),
      },
      // 테두리는 셀 내부에서 꾸미기 때문에 제거 or 최소화
      border: TableBorder.symmetric(
        inside: BorderSide(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      children: [
        // 🔷 헤더 (둥글게)
        TableRow(
          children: [
            Container(
              decoration: BoxDecoration(
                color: tableColor,
                borderRadius: BorderRadius.only(topLeft: radius),
              ),
              padding: edgeInsets,
              child: const Text(
                '순위',
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
                '당첨 복권수',
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
                '1개당 당첨금',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // 🔶 데이터 행들 (둥글게 하고 싶으면 첫/마지막 행에 borderRadius)
        ...games!.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;

          final isFirst = i == 0;
          final isLast = i == games!.length - 1;

          return TableRow(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: isLast ? radius : Radius.zero,
                  ),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                padding: edgeInsets,
                child: Text(r.rank, textAlign: TextAlign.end),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                padding: edgeInsets,
                child: Text(
                  NumberFormat('#,###').format(r.winnerCount),
                  textAlign: TextAlign.end,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: isLast ? radius : Radius.zero,
                  ),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                padding: edgeInsets,
                child: Text(
                  NumberFormat('#,###').format(r.prizePerGame),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
