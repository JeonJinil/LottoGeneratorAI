// 회차별에 맞는 로또 데이터
class LottoData {
  final int round;
  final DateTime pickDate;
  final int totalSell;
  final List<int> winningNumbers;
  final int bonusNumber;
  final List<GameResult> games;
  final List<WinLocation> winLocations;
  final Map<String, int> countAutoWin;

  LottoData({
    required this.round,
    required this.pickDate,
    required this.totalSell,
    required this.winningNumbers,
    required this.bonusNumber,
    required this.games,
    required this.winLocations,
    required this.countAutoWin,
  });
}

// 로또 등수에 따른 게임 결과 (1등 / 4명 / 10억)
class GameResult {
  final String rank;
  final int winnerCount;
  final int prizePerGame;

  GameResult({
    required this.rank,
    required this.winnerCount,
    required this.prizePerGame,
  });
}

class WinLocation {
  final String shopName;
  final String address;
  final bool isAuto;

  WinLocation({
    required this.shopName,
    required this.address,
    required this.isAuto,
  });
}

// 로또 QR 찍었을때 data
class QRResultData {
  final int round;
  final List<QRGame> grGames;

  QRResultData({
    required this.round,
    required this.grGames,
  });
}

// QR안 lotto game
class QRGame {
  final String game;
  final List<int> numbers;
  final String result;

  QRGame({required this.game, required this.numbers, required this.result});
}
