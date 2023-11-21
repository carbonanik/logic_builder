import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../logic3.dart';


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

  Component copyWith({
    List<IO>? input,
    List<IO>? output,
    String? name,
    Offset? pos,
    Size? size,
    DiscreteLogic? logic,
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
  final String id;

  IO({
    required this.id,
    required this.name,
    required this.pos,
  });
}

Component createComponent(
  List<String> inputIds,
  List<String> outputIds,
  Offset pos,
  String name,
) {
  final size = measureSize(inputIds.length, outputIds.length, name);
  final input = generateIOs(inputIds, 0, size.height);
  final output = generateIOs(outputIds, size.width, size.height);

  return Component(
    input: input,
    output: output,
    name: name,
    pos: pos,
    size: size,
  );
}

Size measureSize(int inputCount, int outputCount, String name) {
  final mostIoCount = max(inputCount, outputCount);
  final double height = _calculateHeight(mostIoCount);
  final double width = _calculateWidth(name);
  return Size(width, height);
}

const spaceBetweenIO = 20.0;

double _calculateHeight(int ioCount) {
  return spaceBetweenIO * ioCount + spaceBetweenIO;
// every io get 20 unit space | add 20 unit padding on bottom
}

double _calculateWidth(String name) {
  return 14 * name.length + 2 * 20;
// calculate width using name | add 20 unit padding on left and right
}

List<IO> generateIOs(List<String> ioIds, double xShift, double height) {
  final yShift = (height - _calculateHeight(ioIds.length)) / 2;
  return List.generate(
    ioIds.length,
    (index) => IO(
      id: ioIds[index],
      name: "$index",
      pos: Offset(xShift, _calculateHeight(index) + yShift),
    ),
  );
}

// createAndComponent() {
//   final ownId = const Uuid().v4();
//   final idInA = const Uuid().v4();
//   final idInB = const Uuid().v4();
//
//   final component = createComponent(
//     [idInA, idInB],
//     [ownId],
//     Offset.zero,
//     "AND",
//     [
//       createAnd(
//         ownId,
//         idInA,
//         idInB,
//       )
//     ],
//   );
//   return component;
// }
//
// createOrComponent() {
//   final ownId = const Uuid().v4();
//   final idInA = const Uuid().v4();
//   final idInB = const Uuid().v4();
//
//   final component = createComponent(
//     [idInA, idInB],
//     [ownId],
//     Offset.zero,
//     "OR",
//     [
//       createOr(
//         ownId,
//         idInA,
//         idInB,
//       )
//     ],
//   );
//   return component;
// }
//
// createNotComponent() {
//   final ownId = const Uuid().v4();
//   final idIn = const Uuid().v4();
//
//   final component = createComponent(
//     [idIn],
//     [ownId],
//     Offset.zero,
//     "NOT",
//     [
//       createNot(
//         ownId,
//         idIn,
//       )
//     ],
//   );
//   return component;
// }
//
// createSameTypeComponent(Component example) {
//   switch (example.name) {
//     case "NOT":
//       return createNotComponent();
//     case "AND":
//       return createAndComponent();
//     case "OR":
//       return createOrComponent();
//   }
// }
