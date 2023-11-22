import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum DiscreteComponentType {
  not,
  and,
  nand,
  or,
  nor,
  controlled,
}

class DiscreteComponent {
  // final String id;
  final IO output;
  final DiscreteComponentType type;
  final String name;
  final List<IO> inputs;
  final int state;
  final Offset pos;
  final Size size;

  DiscreteComponent({
    // required this.id,
    required this.output,
    required this.inputs,
    required this.name,
    required this.type,
    required this.state,
    required this.pos,
    required this.size,
  });

  DiscreteComponent copyWith({
    // String? id,
    IO? output,
    DiscreteComponentType? type,
    String? name,
    List<IO>? inputs,
    int? state,
    Offset? pos,
    Size? size,
  }) {
    return DiscreteComponent(
      // id: id ?? this.id,
      output: output ?? this.output,
      type: type ?? this.type,
      name: name ?? this.name,
      inputs: inputs ?? this.inputs,
      state: state ?? this.state,
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

DiscreteComponent createDiscreteComponent({
  required List<String> inputIds,
  required String outputId,
  required Offset pos,
  required String name,
  required DiscreteComponentType type,
}) {
  final double height = _calculateHeight(inputIds.isEmpty ? 1 : inputIds.length);
  final double width = _calculateWidth(name);
  final size = Size(width, height);
  final inputs = generateIOs(inputIds, 0, size.height);
  final output = IO(
    id: outputId,
    name: "out",
    pos: Offset(width, size.height / 2),
  );

  return DiscreteComponent(
    // id: outputId,
    output: output,
    inputs: inputs,
    type: type,
    name: name,
    pos: pos,
    size: size,
    state: 0,
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

DiscreteComponent createNotComponent() {
  final ownId = const Uuid().v4();
  final idIn = const Uuid().v4();

  return createDiscreteComponent(
    inputIds: [idIn],
    outputId: ownId,
    pos: Offset.zero,
    name: "NOT",
    type: DiscreteComponentType.not,
  );
}

DiscreteComponent createAndComponent() {
  final ownId = const Uuid().v4();
  final idInA = const Uuid().v4();
  final idInB = const Uuid().v4();

  return createDiscreteComponent(
    inputIds: [idInA, idInB],
    outputId: ownId,
    pos: Offset.zero,
    name: "AND",
    type: DiscreteComponentType.and,
  );
}

DiscreteComponent createOrComponent() {
  final ownId = const Uuid().v4();
  final idInA = const Uuid().v4();
  final idInB = const Uuid().v4();

  return createDiscreteComponent(
    inputIds: [idInA, idInB],
    outputId: ownId,
    pos: Offset.zero,
    name: "OR",
    type: DiscreteComponentType.or,
  );
}

DiscreteComponent createNandComponent() {
  final ownId = const Uuid().v4();
  final idInA = const Uuid().v4();
  final idInB = const Uuid().v4();

  return createDiscreteComponent(
    inputIds: [idInA, idInB],
    outputId: ownId,
    pos: Offset.zero,
    name: "NAND",
    type: DiscreteComponentType.nand,
  );
}

DiscreteComponent createNorComponent() {
  final ownId = const Uuid().v4();
  final idInA = const Uuid().v4();
  final idInB = const Uuid().v4();

  return createDiscreteComponent(
    inputIds: [idInA, idInB],
    outputId: ownId,
    pos: Offset.zero,
    name: "NOR",
    type: DiscreteComponentType.nor,
  );
}

DiscreteComponent createControlledComponent() {
  final ownId = const Uuid().v4();

  return createDiscreteComponent(
    inputIds: [],
    outputId: ownId,
    pos: Offset.zero,
    name: "Ctrl",
    type: DiscreteComponentType.controlled,
  ).copyWith(state: 1);
}

DiscreteComponent createComponent(DiscreteComponentType type) {
  switch (type) {
    case DiscreteComponentType.not:
      return createNotComponent();
    case DiscreteComponentType.and:
      return createAndComponent();
    case DiscreteComponentType.or:
      return createOrComponent();
    case DiscreteComponentType.nand:
      return createNandComponent();
    case DiscreteComponentType.nor:
      return createNorComponent();
    case DiscreteComponentType.controlled:
      return createControlledComponent();
  }
}
