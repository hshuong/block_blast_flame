import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/game_board.dart';
import '../../models/block_shape.dart';

/// Component hiển thị bảng chơi 8x8 với responsive sizing
class BoardComponent extends PositionComponent {
  final GameBoard board;
  double cellSize;
  double cellMargin;
  
  BlockShape? previewBlock;
  int? previewRow;
  int? previewCol;

  BoardComponent({
    required this.board,
    required this.cellSize,
    required this.cellMargin,
  }) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updateSize();
  }

  void _updateSize() {
    final boardSize = GameBoard.size * (cellSize + cellMargin) + cellMargin;
    size = Vector2.all(boardSize);
  }

  /// Update cell size (cho responsive)
  void updateCellSize(double newCellSize, double newCellMargin) {
    cellSize = newCellSize;
    cellMargin = newCellMargin;
    _updateSize();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Vẽ background
    final bgPaint = Paint()
      ..color = const Color(0xFF1A252F);
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(size.x * 0.04), // Responsive border radius
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Vẽ border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.x * 0.005; // Responsive stroke width
    canvas.drawRRect(bgRect, borderPaint);

    // Vẽ các cells
    for (int row = 0; row < GameBoard.size; row++) {
      for (int col = 0; col < GameBoard.size; col++) {
        _drawCell(canvas, row, col);
      }
    }
  }

  void _drawCell(Canvas canvas, int row, int col) {
    final x = col * (cellSize + cellMargin) + cellMargin;
    final y = row * (cellSize + cellMargin) + cellMargin;
    
    Color? cellColor = board.grid[row][col];
    
    // Kiểm tra preview
    bool isPreview = false;
    Color? previewColor;
    
    if (previewBlock != null && previewRow != null && previewCol != null) {
      int blockRow = row - previewRow!;
      int blockCol = col - previewCol!;

      if (blockRow >= 0 &&
          blockRow < previewBlock!.height &&
          blockCol >= 0 &&
          blockCol < previewBlock!.width) {
        if (previewBlock!.shape[blockRow][blockCol]) {
          isPreview = true;
          previewColor = previewBlock!.color.withOpacity(0.4);
        }
      }
    }

    // Vẽ cell
    final cellRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cellSize, cellSize),
      Radius.circular(cellSize * 0.1),
    );

    if (isPreview && cellColor == null) {
      // Vẽ preview
      final previewPaint = Paint()..color = previewColor!;
      canvas.drawRRect(cellRect, previewPaint);
      
      // Border cho preview
      final borderPaint = Paint()
        ..color = previewBlock!.color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.05;
      canvas.drawRRect(cellRect, borderPaint);
    } else if (cellColor != null) {
      // Vẽ cell đã fill với gradient
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _lightenColor(cellColor, 0.3),
          cellColor,
          _darkenColor(cellColor, 0.2),
        ],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(x, y, cellSize, cellSize),
        );
      canvas.drawRRect(cellRect, paint);
      
      // Border
      final borderPaint = Paint()
        ..color = _darkenColor(cellColor, 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.035;
      canvas.drawRRect(cellRect, borderPaint);
      
      // Highlight
      final highlightSize = cellSize * 0.3;
      final highlightRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + cellSize * 0.05, y + cellSize * 0.05, highlightSize, highlightSize),
        Radius.circular(cellSize * 0.05),
      );
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3);
      canvas.drawRRect(highlightRect, highlightPaint);
    } else {
      // Vẽ empty cell
      final emptyPaint = Paint()..color = Colors.grey.withOpacity(0.05);
      canvas.drawRRect(cellRect, emptyPaint);
      
      final borderPaint = Paint()
        ..color = Colors.grey.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.012;
      canvas.drawRRect(cellRect, borderPaint);
    }
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Cập nhật preview
  void updatePreview(BlockShape? block, int? row, int? col) {
    previewBlock = block;
    previewRow = row;
    previewCol = col;
  }

  /// Convert từ global position sang grid coordinates
  Vector2? globalToGrid(Vector2 globalPos) {
    final localPos = globalPos - position;
    
    final col = ((localPos.x - cellMargin) / (cellSize + cellMargin)).floor();
    final row = ((localPos.y - cellMargin) / (cellSize + cellMargin)).floor();
    
    if (col >= 0 && col < GameBoard.size && row >= 0 && row < GameBoard.size) {
      return Vector2(col.toDouble(), row.toDouble());
    }
    return null;
  }
}