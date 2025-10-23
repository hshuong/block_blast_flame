import 'package:flutter/material.dart';

/// Lớp đại diện cho một khối hình trong game
class BlockShape {
  final List<List<bool>> shape;
  final Color color;
  final String name;

  BlockShape({
    required this.shape,
    required this.color,
    required this.name,
  });

  int get height => shape.length;
  int get width => shape.isEmpty ? 0 : shape[0].length;

  int get blockCount {
    int count = 0;
    for (var row in shape) {
      for (var cell in row) {
        if (cell) count++;
      }
    }
    return count;
  }

  BlockShape copyWith({Color? color}) {
    return BlockShape(
      shape: shape,
      color: color ?? this.color,
      name: name,
    );
  }
}

/// Factory tạo các khối
class BlockShapes {
  // Khối I ngang
  static BlockShape get i1x3 => BlockShape(
    name: 'I1x3',
    color: Colors.cyan,
    shape: [
      [true, true, true],
    ],
  );

  static BlockShape get i1x4 => BlockShape(
    name: 'I1x4',
    color: Colors.cyan,
    shape: [
      [true, true, true, true],
    ],
  );

  // Khối I dọc
  static BlockShape get i3x1 => BlockShape(
    name: 'I3x1',
    color: Colors.cyan,
    shape: [
      [true],
      [true],
      [true],
    ],
  );

  // Khối vuông
  static BlockShape get square1x1 => BlockShape(
    name: 'Square1x1',
    color: Colors.yellow,
    shape: [
      [true],
    ],
  );

  static BlockShape get square2x2 => BlockShape(
    name: 'Square2x2',
    color: Colors.yellow,
    shape: [
      [true, true],
      [true, true],
    ],
  );

  static BlockShape get square3x3 => BlockShape(
    name: 'Square3x3',
    color: Colors.yellow,
    shape: [
      [true, true, true],
      [true, true, true],
      [true, true, true],
    ],
  );

  // Khối L
  static BlockShape get lUp => BlockShape(
    name: 'L_Up',
    color: Colors.blue,
    shape: [
      [true, false],
      [true, false],
      [true, true],
    ],
  );

  static BlockShape get lRight => BlockShape(
    name: 'L_Right',
    color: Colors.blue,
    shape: [
      [true, true, true],
      [true, false, false],
    ],
  );

  // Khối T
  static BlockShape get tUp => BlockShape(
    name: 'T_Up',
    color: Colors.green,
    shape: [
      [true, true, true],
      [false, true, false],
    ],
  );

  static BlockShape get tRight => BlockShape(
    name: 'T_Right',
    color: Colors.green,
    shape: [
      [false, true],
      [true, true],
      [false, true],
    ],
  );

  // Danh sách tất cả khối (compact version)
  static List<BlockShape> get allShapes => [
    i1x3, i1x4, i3x1,
    square1x1, square2x2, square3x3,
    lUp, lRight,
    tUp, tRight,
  ];
}