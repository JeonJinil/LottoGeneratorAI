import 'package:flutter/material.dart';
import 'package:lotto_generator/constant/app_color.dart';
import 'package:lotto_generator/screen/lotto_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    LottoScreen(),
    _Setting(),
    _MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('AI Lotto 생성기')),
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      // bottom navigation 선언
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        selectedItemColor:  navigatorBarColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet),
            label: '당첨 번호',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '번호 생성'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '나의 로또'),
        ],
        currentIndex: _selectedIndex,
        // 지정 인덱스로 이동
        onTap: _onItemTapped, // 선언했던 onItemTapped
      ),
    );
  }
}

class _Setting extends StatelessWidget {
  const _Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('서ㅜㄹ정'));
  }
}

class _MyPage extends StatelessWidget {
  const _MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('마이 페이지'));
  }
}


