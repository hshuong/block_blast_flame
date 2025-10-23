import 'package:flutter/foundation.dart';
import '../models/game_board.dart';
import '../models/block_shape.dart';
import '../utils/block_generator.dart';

class GameStateManager extends ChangeNotifier {
  GameBoard board = GameBoard();
  BlockGenerator generator = BlockGenerator();
  
  List<BlockShape?> currentBlocks = [null, null, null];
  int _score = 0;
  int _highScore = 0;
  int _level = 1;
  int _totalBlocksPlaced = 0;
  bool _isGameOver = false;

  // Getters
  int get score => _score;
  int get highScore => _highScore;
  int get level => _level;
  int get totalBlocksPlaced => _totalBlocksPlaced;
  bool get isGameOver => _isGameOver;

  GameStateManager() {
    _loadHighScore();
    generateNewBlocks();
  }

  void _loadHighScore() {
    // TODO: Load từ SharedPreferences
    _highScore = 0;
  }

  void _saveHighScore() {
    // TODO: Save to SharedPreferences
    if (_score > _highScore) {
      _highScore = _score;
    }
  }

  void generateNewBlocks() {
    final newBlocks = generator.generateBlockSetByLevel(_level);
    for (int i = 0; i < 3; i++) {
      currentBlocks[i] = newBlocks[i];
    }
    notifyListeners();
    print('🎲 Generated blocks: ${currentBlocks.map((b) => b?.name).toList()}');
  }

  bool canPlaceBlock(BlockShape block, int row, int col) {
    return board.canPlaceBlock(block, row, col);
  }

  bool placeBlock(int blockIndex, BlockShape block, int row, int col) {
    if (!board.canPlaceBlock(block, row, col)) {
      return false;
    }

    // Đặt block
    board.placeBlock(block, row, col);
    
    // Cộng điểm
    _score += block.blockCount;
    _totalBlocksPlaced++;
    
    // Xóa block
    currentBlocks[blockIndex] = null;
    
    // Clear full lines
    final clearResult = board.clearFullLines();
    if (clearResult.totalCleared > 0) {
      _score += clearResult.calculateScore();
      print('🎉 Cleared ${clearResult.totalCleared} lines! +${clearResult.calculateScore()} pts');
    }

    // Check level up
    _checkLevelUp();

    // Generate new blocks nếu hết
    if (currentBlocks.every((b) => b == null)) {
      // Delay để animation mượt hơn
      Future.delayed(const Duration(milliseconds: 300), () {
        generateNewBlocks();
      });
    } else {
      // Chỉ notify khi không generate new blocks
      notifyListeners();
    }

    // Check game over
    _checkGameOver();

    // Save high score
    _saveHighScore();

    return true;
  }

  void _checkLevelUp() {
    int requiredBlocks = _level * 10;
    if (_totalBlocksPlaced >= requiredBlocks) {
      _level++;
      print('⭐ LEVEL UP! Now at level $_level');
    }
  }

  void _checkGameOver() {
    // Nếu tất cả blocks đã dùng hết, không game over
    if (currentBlocks.every((block) => block == null)) {
      _isGameOver = false;
      return;
    }

    // Kiểm tra xem có thể đặt bất kỳ block nào không
    for (BlockShape? block in currentBlocks) {
      if (block == null) continue;

      for (int row = 0; row < GameBoard.size; row++) {
        for (int col = 0; col < GameBoard.size; col++) {
          if (board.canPlaceBlock(block, row, col)) {
            _isGameOver = false;
            return;
          }
        }
      }
    }

    // Không thể đặt block nào
    _isGameOver = true;
    notifyListeners();
    print('💀 GAME OVER! Final Score: $_score');
  }

  void resetGame() {
    board.reset();
    _score = 0;
    _isGameOver = false;
    _level = 1;
    _totalBlocksPlaced = 0;
    generateNewBlocks();
    print('🔄 Game Reset');
  }
}