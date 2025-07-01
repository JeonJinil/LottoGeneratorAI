import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lotto_generator/component/crawling_lotto_data.dart';
import 'package:lotto_generator/component/crawling_qr_data.dart';
import 'package:lotto_generator/component/lotto_widget.dart';
import 'package:lotto_generator/screen/lotto/qr_scanner.dart';
import 'package:lotto_generator/screen/lotto/round_winning_numbers_tab.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../component/crawling_lotto.dart';
import '../../constant/app_color.dart';
import '../../model/LottoData.dart';

class LottoMainScreen extends StatefulWidget {
  const LottoMainScreen({super.key});

  @override
  State<LottoMainScreen> createState() => _LottoMainScreen();
}

class _LottoMainScreen extends State<LottoMainScreen> {
  Map<String, dynamic>? lottoData;
  List<LottoRankInfo>? lottoRankInfo;
  int? lastRound;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final latest = await fetchLatestRound();
      if (latest != null) {
        lastRound = latest;
        await _loadRoundData(latest);
      }
    } catch (e) {
      print('초기 로딩 오류: $e');
    }
  }

  Future<void> _loadRoundData(int round) async {
    setState(() => isLoading = true);
    final rankInfo = await fetchLottoRankDetails(round);
    final data = await fetchLottoResult(round);

    setState(() {
      lottoRankInfo = rankInfo;
      lottoData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || lastRound == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(text: '회차별 당첨번호'),
              Tab(text: '회차별 판매점'),
              // Tab(text: 'AI 로또 추천받기'),
              // Tab(text: '내 로또 내역'),
              // ...
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RoundWinningNumbersTab(
              isLoading: isLoading,
              lastRound: lastRound!,
              onSearchPressed: _showRoundPicker,
            ),
            RoundWinningNumbersTab(
              isLoading: isLoading,
              lastRound: lastRound!,
              onSearchPressed: _showRoundPicker,
            ),
          ],
        ),
      ),
    );
  }

  void _showRoundPicker() {
    final parentContext = context;
    if (lastRound == null) return;

    int selectedIndex = 0;
    final roundList = List.generate(lastRound!, (i) => lastRound! - i);

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) => selectedIndex = index,
                  children:
                      roundList.map((r) => Center(child: Text('$r회'))).toList(),
                ),
              ),
              const Divider(height: 1),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      child: const Text('취소'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: CupertinoButton.filled(
                      child: const Text('선택'),
                      onPressed: () async {
                        final selectedRound = roundList[selectedIndex];
                        Navigator.pop(context);
                        final lottoData = await fetchLottoData(selectedRound);
                        _showLottoDetailPopup(parentContext, lottoData);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLottoDetailPopup(BuildContext context, LottoData lottoData) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 10, // 좌우 여백
              vertical: 80, // 상하 여백
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(child: Lotto(lottoData: lottoData)),
          ),
    );
  }


}

class SearchLotto extends StatelessWidget {
  final LottoData lottoData;

  const SearchLotto({super.key, required this.lottoData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("로또 검색")),
      body: Lotto(lottoData: lottoData),
    );
  }
}
