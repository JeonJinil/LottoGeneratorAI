import 'package:flutter/material.dart';
import 'package:lotto_generator/component/crawling_lotto_data.dart';
import 'package:lotto_generator/component/lotto_widget.dart';
import 'package:lotto_generator/constant/app_color.dart';
import 'package:lotto_generator/model/LottoData.dart';

class RoundWinningNumbersTab extends StatelessWidget {
  final bool isLoading;
  final int lastRound;
  final VoidCallback onSearchPressed;

  const RoundWinningNumbersTab({
    Key? key,
    required this.isLoading,
    required this.lastRound,
    required this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 1) 무한 스크롤 리스트
        Expanded(child: InfiniteListPage(lastRound: lastRound)),

        // 2) 회차 검색 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            onPressed: onSearchPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              '회차 검색',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InfiniteListPage extends StatefulWidget {
  final int lastRound;

  const InfiniteListPage({super.key, required this.lastRound});

  @override
  State<InfiniteListPage> createState() => _InfiniteListPageState();
}

class _InfiniteListPageState extends State<InfiniteListPage>
    with AutomaticKeepAliveClientMixin<InfiniteListPage> {
  final List<LottoData> _lottoDataList = [];
  final ScrollController _ctrl = ScrollController();
  bool _isLoading = false; // 로딩 중 플래그
  int _page = 0; // 현재 페이지
  bool _showBackToTop = false; // Up 버튼 보일지 말지

  @override
  void initState() {
    super.initState();
    firstFetch();
    _ctrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onScroll);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true; // ★ 이 부분이 핵심

  // 처음에는 list view 채우기 위해 2개 로드
  void firstFetch() async {
    await _fetchMore();
    await _fetchMore();
  }

  void _onScroll() {
    if (_ctrl.offset > 200 && !_showBackToTop) {
      setState(() => _showBackToTop = true);
    } else if (_ctrl.offset <= 200 && _showBackToTop) {
      setState(() => _showBackToTop = false);
    }

    if (_ctrl.position.pixels >= _ctrl.position.maxScrollExtent - 200 &&
        !_isLoading) {
      // 하단에서 200px 이내로 오면 추가 로드
      _fetchMore();
      _fetchMore();
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    setState(() => _isLoading = true);
    int nowRound = widget.lastRound - _page;

    final lottoData = await fetchLottoData(nowRound);

    setState(() {
      _lottoDataList.add(lottoData);
      _page += 1;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        ListView.builder(
          controller: _ctrl,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _lottoDataList.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _lottoDataList.length) {
              return Lotto(lottoData: _lottoDataList[index]);
            } else {
              // 로딩 스피너
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
        if (_showBackToTop) // 200px 이상 스크롤됐을 때만 보여줌
          Positioned(
            right: 16,
            bottom: 32,
            child: FloatingActionButton(
              onPressed: () {
                _ctrl.animateTo(
                  0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            ),
          ),
      ],
    );
  }
}
