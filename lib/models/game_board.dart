import 'package:flutter/material.dart';
import 'block_shape.dart';

/// Lớp quản lý bảng chơi 8x8
class GameBoard {
  static const int size = 8;
  
  late List<List<Color?>> grid;

  GameBoard() {
    _initializeGrid();
  }

  void _initializeGrid() {
    grid = List.generate(
      size,
      (_) => List.generate(size, (_) => null),
    );
  }

  void reset() {
    _initializeGrid();
  }

  bool isCellEmpty(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      return false;
    }
    return grid[row][col] == null;
  }

  bool canPlaceBlock(BlockShape block, int row, int col) {
    for (int i = 0; i < block.height; i++) {
      for (int j = 0; j < block.width; j++) {
        if (block.shape[i][j]) {
          int targetRow = row + i;
          int targetCol = col + j;
          
          if (!isCellEmpty(targetRow, targetCol)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void placeBlock(BlockShape block, int row, int col) {
    for (int i = 0; i < block.height; i++) {
      for (int j = 0; j < block.width; j++) {
        if (block.shape[i][j]) {
          grid[row + i][col + j] = block.color;
        }
      }
    }
  }

  ClearResult clearFullLines() {
    Set<int> fullRows = {};
    Set<int> fullCols = {};

    // Kiểm tra các hàng ngang
    for (int row = 0; row < size; row++) {
      bool isFull = true;
      for (int col = 0; col < size; col++) {
        if (grid[row][col] == null) {
          isFull = false;
          break;
        }
      }
      if (isFull) {
        fullRows.add(row);
        debugPrint('✅ Row $row is full');
      }
    }

    // Kiểm tra các cột dọc
    for (int col = 0; col < size; col++) {
      bool isFull = true;
      for (int row = 0; row < size; row++) {
        if (grid[row][col] == null) {
          isFull = false;
          break;
        }
      }
      if (isFull) {
        fullCols.add(col);
        debugPrint('✅ Column $col is full');
      }
    }

    // Xóa các hàng đầy
    for (int row in fullRows) {
      for (int col = 0; col < size; col++) {
        grid[row][col] = null;
      }
      debugPrint('🗑️ Cleared row $row');
    }

    // Xóa các cột đầy
    for (int col in fullCols) {
      for (int row = 0; row < size; row++) {
        grid[row][col] = null;
      }
      debugPrint('🗑️ Cleared column $col');
    }

    if (fullRows.isNotEmpty || fullCols.isNotEmpty) {
      debugPrint('🎉 Total cleared: ${fullRows.length} rows + ${fullCols.length} columns');
    }

    return ClearResult(
      rowsCleared: fullRows.length,
      colsCleared: fullCols.length,
    );
  }

  int get emptyCount {
    int count = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell == null) count++;
      }
    }
    return count;
  }

  GameBoard copy() {
    GameBoard newBoard = GameBoard();
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        newBoard.grid[i][j] = grid[i][j];
      }
    }
    return newBoard;
  }

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('Board State:');
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        buffer.write(grid[row][col] == null ? '□ ' : '■ ');
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }
}

class ClearResult {
  final int rowsCleared;
  final int colsCleared;

  ClearResult({
    required this.rowsCleared,
    required this.colsCleared,
  });

  int get totalCleared => rowsCleared + colsCleared;

  int calculateScore() {
    if (totalCleared == 0) return 0;
    
    int baseScore = totalCleared * 8;
    
    if (totalCleared >= 2) {
      baseScore += totalCleared * 10;
    }
    if (totalCleared >= 4) {
      baseScore += totalCleared * 20;
    }
    
    return baseScore;
  }
}