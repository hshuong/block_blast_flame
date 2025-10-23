import 'package:flame/components.dart';
import 'package:flame/events.dart';
//import 'package:flutter/material.dart';
import '../../models/block_shape.dart';
import 'block_component.dart';

/// Component cho khối có thể kéo thả
class DraggableBlockComponent extends BlockComponent with DragCallbacks {
  final Function(int blockIndex, Vector2 startPos) onBlockDragStart;
  final Function(int blockIndex, Vector2 currentPos) onBlockDragUpdate;
  final Function(int blockIndex, Vector2 endPos) onBlockDragEnd;
  
  Vector2? _originalPosition;
  bool _isDragging = false;

  DraggableBlockComponent({
    required BlockShape block,
    required int blockIndex,
    required this.onBlockDragStart,
    required this.onBlockDragUpdate,
    required this.onBlockDragEnd,
    double cellSize = 30.0,
    Vector2? position,
  }) : super(
          block: block,
          blockIndex: blockIndex,
          cellSize: cellSize,
          position: position,
        );

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    
    _isDragging = true;
    isDragging = true;
    _originalPosition = position.clone();
    
    // Đưa component lên trên cùng
    priority = 1000;
    
    print('🎯 Drag started at ${event.localPosition}');
    onBlockDragStart(blockIndex, event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    
    if (!_isDragging) return;
    
    // Cập nhật vị trí của block component theo ngón tay
    // Sử dụng localPosition thay vì canvasPosition
    position += event.localDelta;
    
    onBlockDragUpdate(blockIndex, position);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    
    _isDragging = false;
    isDragging = false;
    priority = 0;
    
    print('🎯 Drag ended at $position');
    onBlockDragEnd(blockIndex, position);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    
    _isDragging = false;
    isDragging = false;
    priority = 0;
    
    // Trả về vị trí ban đầu
    if (_originalPosition != null) {
      position = _originalPosition!;
    }
    
    print('❌ Drag cancelled');
  }

  /// Trả block về vị trí gốc
  void returnToOriginalPosition() {
    if (_originalPosition != null) {
      position = _originalPosition!;
    }
  }
}