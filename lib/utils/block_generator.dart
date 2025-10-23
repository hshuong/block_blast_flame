import 'dart:math';
import '../models/block_shape.dart';

/// Lớp sinh các khối ngẫu nhiên cho game
class BlockGenerator {
  final Random _random = Random();

  /// Sinh một khối ngẫu nhiên từ tất cả các khối có thể
  BlockShape generateRandomBlock() {
    List<BlockShape> allShapes = BlockShapes.allShapes;
    return allShapes[_random.nextInt(allShapes.length)];
  }

  /// Sinh một bộ 3 khối ngẫu nhiên
  List<BlockShape> generateBlockSet() {
    return [
      generateRandomBlock(),
      generateRandomBlock(),
      generateRandomBlock(),
    ];
  }

  /// Sinh khối với độ khó tăng dần theo level
  BlockShape generateBlockByLevel(int level) {
    // Level 1-2: Ưu tiên khối nhỏ
    if (level <= 2) {
      return _generateSmallBlock();
    }
    // Level 3-5: Mix khối nhỏ và vừa
    else if (level <= 5) {
      return _random.nextDouble() < 0.7
          ? _generateSmallBlock()
          : generateRandomBlock();
    }
    // Level 6+: Tất cả các khối
    else {
      return generateRandomBlock();
    }
  }

  /// Sinh khối nhỏ (dễ hơn cho người mới)
  BlockShape _generateSmallBlock() {
    List<BlockShape> smallBlocks = [
      BlockShapes.square1x1,
      BlockShapes.i1x3,
      BlockShapes.i3x1,
      BlockShapes.square2x2,
      BlockShapes.lUp,
      BlockShapes.lRight,
    ];
    return smallBlocks[_random.nextInt(smallBlocks.length)];
  }

  /// Sinh bộ 3 khối theo level
  List<BlockShape> generateBlockSetByLevel(int level) {
    return [
      generateBlockByLevel(level),
      generateBlockByLevel(level),
      generateBlockByLevel(level),
    ];
  }
}