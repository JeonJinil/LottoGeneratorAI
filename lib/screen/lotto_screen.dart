import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:lotto_generator/component/crawling_qr_data.dart';
import 'package:lotto_generator/component/lotto_widget.dart';
import 'package:lotto_generator/constant/app_color.dart';
import 'package:lotto_generator/screen/qr_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../component/crawling_lotto.dart';

class LottoScreen extends StatefulWidget {
  const LottoScreen({super.key});

  @override
  State<LottoScreen> createState() => _LottoScreenState();
}

class _LottoScreenState extends State<LottoScreen> {
  late List<LottoRankInfo> lottoRankInfo;
  late Map<String, dynamic> lottoData;
  late LottoResult lottoResult;

  bool isLoading = true;
  late int lastRound;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      lastRound = (await fetchLatestRound())!;
      final rankInfo = await fetchLottoRankDetails(lastRound);
      final data = await fetchLottoResult(lastRound);
      String url = "https://m.dhlottery.co.kr/qr.do?method=winQr&v=0984q141820323543q111527313240m071012222533n000000000000n0000000000001423157549";
      lottoResult = (await crawlLottoQR(url))!;
      print(lottoResult);

      setState(() {
        lottoRankInfo = rankInfo;
        lottoData = data;
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
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    selectedIndex = index;
                  },
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
                        final data = await fetchLottoResult(selectedRound);
                        setState(() {
                          // if (!lottoDataList.any((e) => e['drwNo'] == selectedRound)) {
                          //   lottoDataList.add(data);
                          // }
                        });
                        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Lotto(lottoData: lottoData, rankInfoList: lottoRankInfo),
                  ElevatedButton(
                    onPressed: () async {
                      var status = await Permission.camera.status;

                      if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
                        // 권한 요청
                        status = await Permission.camera.request();
                      }

                      if (status.isGranted) {
                        // 권한이 있을 경우 QR 스캐너 페이지로 이동
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const QRScannerPage(),
                          ),
                        );

                        // if (result != null && result is String) {
                        //   print("RESULT!~!");
                        //   print(result);
                        //
                        //   Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //       builder: (context) => Scaffold(
                        //         appBar: AppBar(title: const Text('QR 스캔 결과')),
                        //         body: Center(child: Text(result)),
                        //       ),
                        //     ),
                        //   );
                        //   // setState(() {
                        //   //   scannedResult = result;
                        //   // });
                        // }
                      } else {
                        // ❌ 권한 거부됨
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('카메라 권한이 필요합니다.')),
                        );
                      }
                    },
                    child: const Text('qrView'),
                  ),
                ],
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
}


