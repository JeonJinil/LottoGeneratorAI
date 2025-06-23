import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lotto_generator/component/lotto_widget.dart';
import 'package:lotto_generator/constant/app_color.dart';

class LottoScreen extends StatefulWidget {
  const LottoScreen({super.key});

  @override
  State<LottoScreen> createState() => _LottoScreenState();
}

class _LottoScreenState extends State<LottoScreen> {
  List<Map<String, dynamic>> lottoDataList = [];
  bool isLoading = true;
  int lastRound = 1177;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      final data = await fetchLottoResult(lastRound);
      setState(() {
        lottoDataList.add(data);
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showInputDialog() async {
    int selectedIndex = 0;
    List<int> roundList = List.generate(lastRound, (i) => lastRound - i);

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
                  scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    selectedIndex = index;
                  },
                  children: roundList.map((r) => Center(child: Text('$r회'))).toList(),
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
                        final data = await fetchLottoResult(selectedRound);
                        setState(() {
                          if (!lottoDataList.any((e) => e['drwNo'] == selectedRound)) {
                            lottoDataList.add(data);
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text('로또 당첨 번호 조회'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: lottoDataList.map((data) {
          return Lotto(
            key: ValueKey(data['drwNo']),
            lottoData: data,
            onDelete: () {
              setState(() {
                lottoDataList.removeWhere((e) => e['drwNo'] == data['drwNo']);
              });
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CupertinoButton.filled(
            child: const Text('회차 추가하기'),
            onPressed: _showInputDialog,
          ),
        ),
      ),
    );
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
}