import 'package:flame/game.dart';
import 'package:flame/components.dart';
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
  double boardY = 0;
  double blockY = 0;
  double titleFontSize = 32;
  double scoreFontSize = 24;
  double instructionFontSize = 14;

  BlockBlastGame({required this.gameState});

  @override
  Color backgroundColor() => const Color(0xFF0F2027);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    _calculateResponsiveSizes();
    
    // Tạo board component với kích thước responsive
    boardComponent = BoardComponent(
      board: gameState.board,
      cellSize: cellSize,
      cellMargin: cellMargin,
    );
    boardComponent!.position = Vector2(size.x / 2, boardY);
    await add(boardComponent!);
    
    // Tạo blocks
    _regenerateBlocks();
    
    // Listen to state changes
    gameState.addListener(_onGameStateChanged);
  }

  void _calculateResponsiveSizes() {
    // Tính toán dựa trên kích thước màn hình nhỏ hơn
    final minDimension = size.x < size.y ? size.x : size.y;
    
    // Board chiếm khoảng 85% chiều rộng màn hình
    final boardWidth = size.x * 0.85;
    cellSize = (boardWidth - 10) / 8.5; // 8 cells + margins
    cellMargin = cellSize * 0.05;
    
    // Block size nhỏ hơn cell size một chút
    blockCellSize = cellSize * 0.65;
    
    // Vị trí responsive - Di chuyển board xuống để tránh che chữ
    boardY = size.y * 0.45; // Tăng từ 0.40 lên 0.45
    blockY = size.y * 0.85; // Tăng từ 0.80 lên 0.85
    
    // Font sizes responsive
    titleFontSize = minDimension * 0.08;
    scoreFontSize = minDimension * 0.06;
    instructionFontSize = minDimension * 0.035;
    
    debugPrint('📐 Responsive sizes - cellSize: $cellSize, blockCellSize: $blockCellSize');
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    // Tính toán lại kích thước khi màn hình thay đổi
    _calculateResponsiveSizes();
    
    // Cập nhật board nếu đã được khởi tạo
    if (boardComponent != null) {
      boardComponent!.updateCellSize(cellSize, cellMargin);
      boardComponent!.position = Vector2(size.x / 2, boardY);
      
      // Cập nhật vị trí blocks
      _updateBlockPositions();
    }
  }

  void _onGameStateChanged() {
    // Remove old board component và tạo mới
    if (boardComponent != null) {
      boardComponent!.removeFromParent();
    }
    
    boardComponent = BoardComponent(
      board: gameState.board,
      cellSize: cellSize,
      cellMargin: cellMargin,
    );
    boardComponent!.position = Vector2(size.x / 2, boardY);
    add(boardComponent!);
    
    // Regenerate blocks if needed
    _regenerateBlocks();
  }

  void _regenerateBlocks() {
    // Clear old components
    for (var comp in blockComponents) {
      comp?.removeFromParent();
    }
    
    // Đếm số block thực tế
    List<int> activeBlockIndices = [];
    for (int i = 0; i < 3; i++) {
      if (gameState.currentBlocks[i] != null) {
        activeBlockIndices.add(i);
      }
    }
    
    if (activeBlockIndices.isEmpty) return;
    
    // Tính toán khoảng cách để căn giữa
    final blockSpacing = size.x * 0.25; // Khoảng cách giữa các block
    final totalWidth = blockSpacing * (activeBlockIndices.length - 1);
    final startX = (size.x - totalWidth) / 2;
    
    // Tạo components mới với vị trí căn giữa
    int positionIndex = 0;
    for (int i = 0; i < 3; i++) {
      if (gameState.currentBlocks[i] != null) {
        final xPos = startX + (blockSpacing * positionIndex);
        
        final blockComp = DraggableBlockComponent(
          block: gameState.currentBlocks[i]!,
          blockIndex: i,
          cellSize: blockCellSize,
          position: Vector2(xPos, blockY),
          onBlockDragStart: _handleBlockDragStart,
          onBlockDragUpdate: _handleBlockDragUpdate,
          onBlockDragEnd: _handleBlockDragEnd,
        );
        blockComponents[i] = blockComp;
        add(blockComp);
        positionIndex++;
      } else {
        blockComponents[i] = null;
      }
    }
  }

  void _updateBlockPositions() {
    // Đếm số block thực tế
    List<int> activeBlockIndices = [];
    for (int i = 0; i < 3; i++) {
      if (blockComponents[i] != null) {
        activeBlockIndices.add(i);
      }
    }
    
    if (activeBlockIndices.isEmpty) return;
    
    // Tính toán khoảng cách để căn giữa
    final blockSpacing = size.x * 0.25;
    final totalWidth = blockSpacing * (activeBlockIndices.length - 1);
    final startX = (size.x - totalWidth) / 2;
    
    // Cập nhật vị trí
    int positionIndex = 0;
    for (int i = 0; i < 3; i++) {
      if (blockComponents[i] != null) {
        final xPos = startX + (blockSpacing * positionIndex);
        blockComponents[i]!.position = Vector2(xPos, blockY);
        positionIndex++;
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

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Vẽ title ở vị trí cao hơn
    final textPaint = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: titleFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    textPaint.render(
      canvas,
      'BLOCK BLAST',
      Vector2(size.x / 2, size.y * 0.05), // Giảm từ 0.08 xuống 0.05
      anchor: Anchor.center,
    );
    
    // Không vẽ score ở đây nữa vì đã có trong game_screen.dart
    
    // Vẽ instruction
    final instructionPaint = TextPaint(
      style: TextStyle(
        color: Colors.white.withOpacity(0.6),
        fontSize: instructionFontSize,
      ),
    );
    instructionPaint.render(
      canvas,
      '👆 Drag blocks to the board',
      Vector2(size.x / 2, size.y * 0.72), // Điều chỉnh vị trí
      anchor: Anchor.center,
    );
  }
}