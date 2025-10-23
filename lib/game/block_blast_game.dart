import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/game_board.dart';
import 'components/board_component.dart';
import 'components/draggable_block_component.dart';
import 'game_state_manager.dart';

class BlockBlastGame extends FlameGame {
  final GameStateManager gameState;
  late BoardComponent boardComponent;
  
  final List<DraggableBlockComponent?> blockComponents = [null, null, null];

  BlockBlastGame({required this.gameState});

  @override
  Color backgroundColor() => const Color(0xFF0F2027);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Tạo board component
    boardComponent = BoardComponent(
      board: gameState.board,
      cellSize: 42,
      cellMargin: 2,
    );
    boardComponent.position = Vector2(size.x / 2, size.y * 0.4);
    await add(boardComponent);
    
    // Tạo blocks
    _regenerateBlocks();
    
    // Listen to state changes
    gameState.addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    // Remove old board component và tạo mới
    boardComponent.removeFromParent();
    
    boardComponent = BoardComponent(
      board: gameState.board,
      cellSize: 42,
      cellMargin: 2,
    );
    boardComponent.position = Vector2(size.x / 2, size.y * 0.4);
    add(boardComponent);
    
    // Regenerate blocks if needed
    _regenerateBlocks();
  }

  void _regenerateBlocks() {
    // Clear old components
    for (var comp in blockComponents) {
      comp?.removeFromParent();
    }
    
    // Tạo components mới
    final blockY = size.y * 0.85;
    final spacing = size.x / 4;
    
    for (int i = 0; i < 3; i++) {
      if (gameState.currentBlocks[i] != null) {
        final blockComp = DraggableBlockComponent(
          block: gameState.currentBlocks[i]!,
          blockIndex: i,
          cellSize: 28,
          position: Vector2(spacing * (i + 1), blockY),
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

  void _handleBlockDragStart(int blockIndex, Vector2 startPos) {
    print('🎮 Start dragging block $blockIndex');
    boardComponent.updatePreview(null, null, null);
  }

  void _handleBlockDragUpdate(int blockIndex, Vector2 currentPos) {
    if (gameState.currentBlocks[blockIndex] == null) return;
    
    final blockComp = blockComponents[blockIndex];
    if (blockComp == null) return;
    
    final boardLocalPos = currentPos - boardComponent.position + 
                          Vector2(boardComponent.size.x / 2, boardComponent.size.y / 2);
    
    final gridPos = _localToGrid(boardLocalPos);
    
    if (gridPos != null) {
      final block = gameState.currentBlocks[blockIndex]!;
      final row = gridPos.y.toInt();
      final col = gridPos.x.toInt();
      
      final centerRow = row - (block.height ~/ 2);
      final centerCol = col - (block.width ~/ 2);
      
      if (gameState.canPlaceBlock(block, centerRow, centerCol)) {
        boardComponent.updatePreview(block, centerRow, centerCol);
      } else {
        boardComponent.updatePreview(null, null, null);
      }
    } else {
      boardComponent.updatePreview(null, null, null);
    }
  }

  void _handleBlockDragEnd(int blockIndex, Vector2 endPos) {
    print('🎮 End dragging block $blockIndex');
    
    if (gameState.currentBlocks[blockIndex] == null) return;
    
    final boardLocalPos = endPos - boardComponent.position + 
                          Vector2(boardComponent.size.x / 2, boardComponent.size.y / 2);
    
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
        print('✅ Block placed! Score: ${gameState.score}');
      }
    }
    
    if (!placed) {
      blockComponents[blockIndex]?.returnToOriginalPosition();
      print('❌ Cannot place block here');
    }
    
    boardComponent.updatePreview(null, null, null);
  }

  Vector2? _localToGrid(Vector2 localPos) {
    const cellSize = 42.0;
    const cellMargin = 2.0;
    
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Vẽ title
    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.render(
      canvas,
      'BLOCK BLAST',
      Vector2(size.x / 2, 50),
      anchor: Anchor.center,
    );
    
    // Vẽ score
    final scorePaint = TextPaint(
      style: const TextStyle(
        color: Colors.amber,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    scorePaint.render(
      canvas,
      'Score: ${gameState.score}',
      Vector2(size.x / 2, 100),
      anchor: Anchor.center,
    );
    
    // Vẽ instruction
    final instructionPaint = TextPaint(
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: 14,
      ),
    );
    instructionPaint.render(
      canvas,
      '👆 Drag blocks to the board',
      Vector2(size.x / 2, size.y * 0.7),
      anchor: Anchor.center,
    );
  }
}