import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool isScanned = false;

  void handleDetect(BarcodeCapture capture) {
    if (isScanned) return;

    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null) {
      isScanned = true;
      // Navigator.pop(context, code);

      if (code != null && code is String) {
        print("code!!");
        print(code);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('QR 스캔 결과')),
              body: Center(child: Text(code)),
            ),
          ),
        );
        // setState(() {
        //   scannedResult = result;
        // });
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