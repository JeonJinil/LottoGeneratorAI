import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotto_generator/component/crawling_lotto_data.dart';
import 'package:lotto_generator/component/crawling_qr_data.dart';
import 'package:lotto_generator/model/LottoData.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lotto_generator/model/LottoData.dart';
import '../../component/crawling_lotto.dart';
import '../../constant/app_color.dart';
import 'lotto_detail_screen.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isScanned = false;

  String normalizeLottoUrl(String rawUrl) {
    final uri = Uri.parse(rawUrl);

    if (uri.host.contains("dhlottery.co.kr") &&
        uri.queryParameters.containsKey("v")) {
      return 'https://m.dhlottery.co.kr/qr.do?method=winQr&v=${uri.queryParameters["v"]}';
    }

    return rawUrl; // fallback: 원래 URL 그대로 사용
  }

  void handleDetect(BarcodeCapture capture) async {
    if (isScanned) return;

    final barcode = capture.barcodes.first;
    String? url = barcode.rawValue;

    if (url != null) {
      setState(() {
        isScanned = true;
      });

      url = normalizeLottoUrl(url);
      print("📦 QR 인식됨: $url");

      final QRResultData? qrResultData = await fetchQRData(url);
      final LottoData lottoData = await fetchLottoData(qrResultData!.round);
      if (QRResultData != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LottoDetailScreen(qrResultData: qrResultData, lottoData : lottoData),
          ),
        );
      } else {
        // 에러 처리: 데이터를 못 불러왔을 때 UI 띄우기
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('데이터를 불러올 수 없습니다.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR 스캐너')),
      body: MobileScanner(
        // allowDuplicates: false,
        onDetect: handleDetect, // ✅ 이건 위의 handleDetect 함수와 연결됨
      ),
    );
  }
}
