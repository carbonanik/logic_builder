import 'dart:math';

import 'package:flutter/material.dart';

class Part {
  final List<IO> input;
  final List<IO> output;
  final String name;
  final Offset pos;
  final Size size;

  Part({
    required this.input,
    required this.output,
    required this.name,
    required this.pos,
    required this.size,
  });

  factory Part.fromIoCount(int inputCount, int outputCount, Offset pos, String name) {
    final size = measureSize(inputCount, outputCount, name);
    final input = generateIOs(inputCount, 0);
    final output = generateIOs(outputCount, size.width);

    return Part(
      input: input,
      output: output,
      name: name,
      pos: pos,
      size: size,
    );
  }

  static Size measureSize(int inputCount, int outputCount, String name) {
    final most = max(inputCount, outputCount);
    final double height = most * 20 + 20;
    return Size(name.length * 14 + 2 * 20, height);
  }

  static generateIOs(int count, double xShift) {
    return List.generate(
      count,
      (index) => IO(
        name: "$index",
        pos: Offset(xShift, (index + 1) * 20),
      ),
    );
  }

  Part copyWith({
    List<IO>? input,
    List<IO>? output,
    String? name,
    Offset? pos,
    Size? size,
  }) {
    return Part(
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
