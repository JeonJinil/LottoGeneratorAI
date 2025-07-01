import 'package:flutter/material.dart';
import 'package:lotto_generator/constant/app_color.dart';
import 'package:lotto_generator/screen/lotto/lotto_main_screen.dart';
import 'package:lotto_generator/screen/lotto/qr_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[LottoMainScreen(), _Setting()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 로또, 스피또'),
        // leading: IconButton(
        //   icon: const Icon(Icons.menu),
        //   onPressed: () {},
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_rounded),
            onPressed: _handleQRScan,
          ),
        ],
      ),
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      // bottom navigation 선언
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        selectedItemColor: navigatorBarColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.circle, color: Colors.amber, size: 32),
            label: '로또',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star, color: Colors.yellow, size: 28),
            label: '스피또',
          ),
        ],
        currentIndex: _selectedIndex,
        // 지정 인덱스로 이동
        onTap: _onItemTapped, // 선언했던 onItemTapped
      ),
    );
  }

  Future<void> _handleQRScan() async {
    var status = await Permission.camera.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QRScannerPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카메라 권한이 필요합니다.')));
    }
  }
}

class _Setting extends StatelessWidget {
  const _Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('스피또 TODO'));
  }
}

