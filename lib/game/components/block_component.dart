import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/block_shape.dart';

/// Component hiển thị một khối
class BlockComponent extends PositionComponent {
  final BlockShape block;
  final double cellSize;
  final int blockIndex;
  
  bool isDragging = false;

  BlockComponent({
    required this.block,
    required this.blockIndex,
    this.cellSize = 30.0,
    Vector2? position,
  }) : super(
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final blockWidth = block.width * cellSize;
    final blockHeight = block.height * cellSize;
    size = Vector2(blockWidth, blockHeight);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Vẽ shadow nếu đang drag
    if (isDragging) {
      final shadowPaint = Paint()
        ..color = block.color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      for (int i = 0; i < block.height; i++) {
        for (int j = 0; j < block.width; j++) {
          if (block.shape[i][j]) {
            final x = j * cellSize - size.x / 2;
            final y = i * cellSize - size.y / 2;
            
            final shadowRect = RRect.fromRectAndRadius(
              Rect.fromLTWH(x + 3, y + 3, cellSize, cellSize),
              const Radius.circular(4),
            );
            canvas.drawRRect(shadowRect, shadowPaint);
          }
        }
      }
    }

    // Vẽ các cells của khối
    for (int i = 0; i < block.height; i++) {
      for (int j = 0; j < block.width; j++) {
        if (block.shape[i][j]) {
          _drawBlockCell(canvas, i, j);
        }
      }
    }
  }

  void _drawBlockCell(Canvas canvas, int row, int col) {
    final x = col * cellSize - size.x / 2;
    final y = row * cellSize - size.y / 2;
    
    final cellRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cellSize, cellSize),
      const Radius.circular(4),
    );

    // Gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _lightenColor(block.color, 0.3),
        block.color,
        _darkenColor(block.color, 0.2),
      ],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(x, y, cellSize, cellSize),
      );
    canvas.drawRRect(cellRect, paint);
    
    // Border
    final borderPaint = Paint()
      ..color = _darkenColor(block.color, 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(cellRect, borderPaint);
    
    // Highlight
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + 2, y + 2, cellSize * 0.3, cellSize * 0.3),
      const Radius.circular(2),
    );
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4);
    canvas.drawRRect(highlightRect, highlightPaint);
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
}