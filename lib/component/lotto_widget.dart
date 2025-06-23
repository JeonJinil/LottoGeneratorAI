import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotto_generator/constant/app_color.dart';

class Lotto extends StatelessWidget {
  final Map<String, dynamic>? lottoData;
  final VoidCallback? onDelete;

  const Lotto({super.key, this.lottoData, this.onDelete});

  @override
  Widget build(BuildContext context) {
    List<int> lottoNumbers = [];
    for (int i = 1; i <= 6; i++) {
      lottoNumbers.add(lottoData!['drwtNo$i'] as int);
    }

    return GestureDetector(
      onTap: () {
        // 탭 시 상세보기 다이얼로그
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('${lottoData!['drwNo']}회차 상세 정보'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('날짜: ${lottoData!['drwNoDate']}'),
                    Text(
                      '번호: ${lottoNumbers.join(', ')} + ${lottoData!['bnusNo']}',
                    ),
                    Text(
                      '1등 당첨금: ${NumberFormat('#,###').format(lottoData!['firstWinamnt'])}원',
                    ),
                    Text('1등 당첨자 수: ${lottoData!['firstPrzwnerCo']}명'),
                    Text(
                      '홀: ${lottoNumbers.where((num) => num.isOdd).length}: ${lottoNumbers.where((num) => num.isEven).length} 짝',
                    ),
                    Text(
                      '저 : ${lottoNumbers.where((num) => num <= 23).length}, 고 : ${lottoNumbers.where((num) => num > 23).length}',
                    ),
                    Text('고저차 : ${lottoNumbers[5] - lottoNumbers[0]}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                ],
              ),
        );
      },
      onLongPress: () {
        // 길게 눌렀을 때
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('삭제 확인'),
                content: const Text('이 회차 카드를 삭제하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('아니오'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onDelete != null) onDelete!();
                    },
                    child: const Text('예', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
        );
      },
      child: Card(
        color: lottoCardColor,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                Text(
                  '${lottoData!['drwNo']}회차 (${lottoData!['drwNoDate'].toString()})',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                _Middle(lottoData: lottoData, lottoNumbers: lottoNumbers),
                const SizedBox(height: 20),
                _Bottom(lottoData: lottoData),
              ],
            ),
          ),
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
  final Map<String, dynamic>? lottoData;

  const _Bottom({required this.lottoData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '1등 당첨금: ${NumberFormat('#,###').format(lottoData!['firstWinamnt'])}원',
        ),
        Text('당첨자 수: ${lottoData!['firstPrzwnerCo']}명'),
      ],
    );
  }
}
