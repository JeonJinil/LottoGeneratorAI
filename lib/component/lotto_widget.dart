import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotto_generator/constant/app_color.dart';

import 'crawling_lotto.dart';

class Lotto extends StatelessWidget {
  final Map<String, dynamic>? lottoData;
  final List<LottoRankInfo>? rankInfoList; //

  const Lotto({super.key, this.lottoData, this.rankInfoList});

  @override
  Widget build(BuildContext context) {
    List<int> lottoNumbers = [];
    for (int i = 1; i <= 6; i++) {
      lottoNumbers.add(lottoData!['drwtNo$i'] as int);
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children:[
            Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${lottoData!['drwNo']}회 ',

                        style: TextStyle(
                          color: Color(0xFF216AF3),
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      Text(
                        '당첨번호',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '(${lottoData!['drwNoDate'].toString()}일 추첨)',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                _Middle(lottoData: lottoData, lottoNumbers: lottoNumbers),
                const SizedBox(height: 20),
                Text(
                  '총 판매금액: ${NumberFormat('#,###').format(lottoData!['totSellamnt'])}원',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            _Bottom(rankInfoList: rankInfoList),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _Middle extends StatelessWidget {
  final Map<String, dynamic>? lottoData;
  final List<int> lottoNumbers;

  const _Middle({required this.lottoData, required this.lottoNumbers});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 2.0,
      children: [
        ...lottoNumbers.map(
          (num) => CircleAvatar(
            backgroundColor: getBallColor(num),
            child: Text('$num', style: TextStyle(color: Colors.white)),
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.transparent, // 배경 없애고
          child: Text(
            '+',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        CircleAvatar(
          backgroundColor: getBallColor(lottoData!['bnusNo']),
          child: Text(
            '${lottoData!['bnusNo']}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _Bottom extends StatelessWidget {
  final List<LottoRankInfo>? rankInfoList;

  const _Bottom({super.key, this.rankInfoList});

  @override
  Widget build(BuildContext context) {


    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2.2),
      },
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFE0F2F1)),
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('순위', textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('당첨 복권수', textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('총 당첨금', textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        ...rankInfoList!.map((r) =>
            TableRow(
              children: [
                Padding(padding: const EdgeInsets.all(8),
                    child: Text('${r.rank}', textAlign: TextAlign.end,)),
                Padding(padding: const EdgeInsets.all(8),
                    child: Text(r.winnerCount, textAlign: TextAlign.end,)),
                Padding(padding: const EdgeInsets.all(8),
                    child: Text(r.prizePerGame, textAlign: TextAlign.end)),
              ],
            )),
      ],
    );
  }
}
