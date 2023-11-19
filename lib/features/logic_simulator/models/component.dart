import 'dart:math';

import 'package:flutter/material.dart';

class Component {
  final List<IO> input;
  final List<IO> output;
  final String name;
  final Offset pos;
  final Size size;

  Component({
    required this.input,
    required this.output,
    required this.name,
    required this.pos,
    required this.size,
  });

  factory Component.fromIoCount(
    int inputCount,
    int outputCount,
    Offset pos,
    String name,
  ) {
    final size = measureSize(inputCount, outputCount, name);
    final input = generateIOs(inputCount, 0, size.height);
    final output = generateIOs(outputCount, size.width, size.height);

    return Component(
      input: input,
      output: output,
      name: name,
      pos: pos,
      size: size,
    );
  }

  static Size measureSize(int inputCount, int outputCount, String name) {
    final mostIoCount = max(inputCount, outputCount);
    final double height = _calculateHeight(mostIoCount);
    final double width = _calculateWidth(name);
    return Size(width, height);
  }

  static const spaceBetweenIO = 20.0;

  static double _calculateHeight(int ioCount) {
    return spaceBetweenIO * ioCount + spaceBetweenIO;
    // every io get 20 unit space | add 20 unit padding on bottom
  }

  static double _calculateWidth(String name) {
    return 14 * name.length + 2 * 20;
    // calculate width using name | add 20 unit padding on left and right
  }

  static List<IO> generateIOs(int count, double xShift, double height) {
    final yShift = (height - _calculateHeight(count)) / 2;
    return List.generate(
      count,
      (index) => IO(
        name: "$index",
        pos: Offset(xShift, _calculateHeight(index) + yShift),
      ),
    );
  }

  Component copyWith({
    List<IO>? input,
    List<IO>? output,
    String? name,
    Offset? pos,
    Size? size,
  }) {
    return Component(
      input: input ?? this.input,
      output: output ?? this.output,
      name: name ?? this.name,
      pos: pos ?? this.pos,
      size: size ?? this.size,
    );
  }
}

class IO {
  final String name;
  final Offset pos;

  IO({
    required this.name,
    required this.pos,
  });
}
