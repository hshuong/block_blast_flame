// lib/game/block_blast_game.dart
import 'package:flame/game.dart';
//import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/game_board.dart';
import 'components/board_component.dart';
import 'components/draggable_block_component.dart';
import 'game_state_manager.dart';

class BlockBlastGame extends FlameGame {
  final GameStateManager gameState;
  BoardComponent? boardComponent;
  
  final List<DraggableBlockComponent?> blockComponents = [null, null, null];
  
  // Responsive sizing variables
  double cellSize = 42;
  double cellMargin = 2;
  double blockCellSize = 28;

  BlockBlastGame({required this.gameState});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    _calculateResponsiveSizes();
    
    // Tạo board component - đặt ở giữa màn hình game
    boardComponent = BoardComponent(
      board: gameState.board,
      cellSize: cellSize,
      cellMargin: cellMargin,
    );
    boardComponent!.position = Vector2(size.x / 2, size.y * 0.35);
    await add(boardComponent!);
    
    // Tạo blocks
    _regenerateBlocks();
    
    // Listen to state changes
    gameState.addListener(_onGameStateChanged);
  }

  void _calculateResponsiveSizes() {
    // Board chiếm khoảng 90% chiều rộng game area
    final boardWidth = size.x * 0.90;
    cellSize = (boardWidth - 10) / 8.5;
    cellMargin = cellSize * 0.05;
    
    // Block size nhỏ hơn cell size
    blockCellSize = cellSize * 0.65;
    
    debugPrint('📐 Game sizes - cellSize: $cellSize, blockCellSize: $blockCellSize');
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    _calculateResponsiveSizes();
    
    if (boardComponent != null) {
      boardComponent!.updateCellSize(cellSize, cellMargin);
      boardComponent!.position = Vector2(size.x / 2, size.y * 0.35);
      _updateBlockPositions();
    }
  }

  void _onGameStateChanged() {
    if (boardComponent != null) {
      boardComponent!.removeFromParent();
    }
    
    boardComponent = BoardComponent(
      board: gameState.board,
      cellSize: cellSize,
      cellMargin: cellMargin,
    );
    boardComponent!.position = Vector2(size.x / 2, size.y * 0.35);
    add(boardComponent!);
    
    _regenerateBlocks();
  }

  void _regenerateBlocks() {
    // Clear old components
    for (var comp in blockComponents) {
      comp?.removeFromParent();
    }
    
    // Tính toán 3 vị trí cố định cho blocks
    // Chia màn hình thành 4 phần, blocks ở vị trí 1/4, 2/4, 3/4
    final position1 = size.x * 0.25; // 25% từ trái
    final position2 = size.x * 0.50; // 50% từ trái (giữa)
    final position3 = size.x * 0.75; // 75% từ trái
    
    final blockY = size.y * 0.85;
    
    final fixedPositions = [position1, position2, position3];
    
    // Tạo components cho từng vị trí cố định
    for (int i = 0; i < 3; i++) {
      if (gameState.currentBlocks[i] != null) {
        final blockComp = DraggableBlockComponent(
          block: gameState.currentBlocks[i]!,
          blockIndex: i,
          cellSize: blockCellSize,
          position: Vector2(fixedPositions[i], blockY),
          onBlockDragStart: _handleBlockDragStart,
          onBlockDragUpdate: _handleBlockDragUpdate,
          onBlockDragEnd: _handleBlockDragEnd,
        );
        blockComponents[i] = blockComp;
        add(blockComp);
      } else {
        blockComponents[i] = null;
      }
    }
  }

  void _updateBlockPositions() {
    // 3 vị trí cố định
    final position1 = size.x * 0.25;
    final position2 = size.x * 0.50;
    final position3 = size.x * 0.75;
    final blockY = size.y * 0.85;
    
    final fixedPositions = [position1, position2, position3];
    
    for (int i = 0; i < 3; i++) {
      if (blockComponents[i] != null) {
        blockComponents[i]!.position = Vector2(fixedPositions[i], blockY);
      }
    }
  }

  void _handleBlockDragStart(int blockIndex, Vector2 startPos) {
    debugPrint('🎮 Start dragging block $blockIndex');
    boardComponent?.updatePreview(null, null, null);
  }

  void _handleBlockDragUpdate(int blockIndex, Vector2 currentPos) {
    if (gameState.currentBlocks[blockIndex] == null || boardComponent == null) return;
    
    final blockComp = blockComponents[blockIndex];
    if (blockComp == null) return;
    
    final boardLocalPos = currentPos - boardComponent!.position + 
                          Vector2(boardComponent!.size.x / 2, boardComponent!.size.y / 2);
    
    final gridPos = _localToGrid(boardLocalPos);
    
    if (gridPos != null) {
      final block = gameState.currentBlocks[blockIndex]!;
      final row = gridPos.y.toInt();
      final col = gridPos.x.toInt();
      
      final centerRow = row - (block.height ~/ 2);
      final centerCol = col - (block.width ~/ 2);
      
      if (gameState.canPlaceBlock(block, centerRow, centerCol)) {
        boardComponent!.updatePreview(block, centerRow, centerCol);
      } else {
        boardComponent!.updatePreview(null, null, null);
      }
    } else {
      boardComponent!.updatePreview(null, null, null);
    }
  }

  void _handleBlockDragEnd(int blockIndex, Vector2 endPos) {
    debugPrint('🎮 End dragging block $blockIndex');
    
    if (gameState.currentBlocks[blockIndex] == null || boardComponent == null) return;
    
    final boardLocalPos = endPos - boardComponent!.position + 
                          Vector2(boardComponent!.size.x / 2, boardComponent!.size.y / 2);
    
    final gridPos = _localToGrid(boardLocalPos);
    bool placed = false;
    
    if (gridPos != null) {
      final block = gameState.currentBlocks[blockIndex]!;
      final row = gridPos.y.toInt();
      final col = gridPos.x.toInt();
      
      final centerRow = row - (block.height ~/ 2);
      final centerCol = col - (block.width ~/ 2);
      
      placed = gameState.placeBlock(blockIndex, block, centerRow, centerCol);
      
      if (placed) {
        debugPrint('✅ Block placed! Score: ${gameState.score}');
      }
    }
    
    if (!placed) {
      blockComponents[blockIndex]?.returnToOriginalPosition();
      debugPrint('❌ Cannot place block here');
    }
    
    boardComponent?.updatePreview(null, null, null);
  }

  Vector2? _localToGrid(Vector2 localPos) {
    final col = ((localPos.x - cellMargin) / (cellSize + cellMargin)).floor();
    final row = ((localPos.y - cellMargin) / (cellSize + cellMargin)).floor();
    
    if (col >= 0 && col < GameBoard.size && row >= 0 && row < GameBoard.size) {
      return Vector2(col.toDouble(), row.toDouble());
    }
    return null;
  }

  @override
  void onRemove() {
    gameState.removeListener(_onGameStateChanged);
    super.onRemove();
  }
}