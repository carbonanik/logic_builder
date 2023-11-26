import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logic_builder/features/logic_canvas/models/offset_map.dart';
import 'package:logic_builder/features/logic_canvas/models/size_map.dart';
import 'package:uuid/uuid.dart';
import 'package:logic_builder/features/logic_canvas/models/component_view_type.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component_type.dart';
import 'package:logic_builder/features/logic_canvas/models/io.dart';




class DiscreteComponent {
  final IO output;
  final DiscreteComponentType type;
  final ComponentViewType viewType;
  final String name;
  final List<IO> inputs;
  final int state;
  final Offset pos;
  final Size size;

  DiscreteComponent({
    required this.output,
    required this.inputs,
    required this.name,
    required this.type,
    required this.viewType,
    required this.state,
    required this.pos,
    required this.size,
  });

  DiscreteComponent copyWith({
    IO? output,
    DiscreteComponentType? type,
    ComponentViewType? viewType,
    String? name,
    List<IO>? inputs,
    int? state,
    Offset? pos,
    Size? size,
  }) {
    return DiscreteComponent(
      output: output ?? this.output,
      type: type ?? this.type,
      viewType: viewType ?? this.viewType,
      name: name ?? this.name,
      inputs: inputs ?? this.inputs,
      state: state ?? this.state,
      pos: pos ?? this.pos,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'output': output.toMap(),
      'inputs': inputs.map((e) => e.toMap()).toList(),
      'type': type.name,
      'viewType': viewType.name,
      'name': name,
      'state': state,
      'pos': pos.toMap(),
      'size': size.toMap(),
    };
  }

  factory DiscreteComponent.fromMap(Map<String, dynamic> map) {
    return DiscreteComponent(
      output: IO.fromMap(map['output']),
      inputs: (map['inputs'] as List).map((e) => IO.fromMap(e)).toList(),
      type: DiscreteComponentType.values.firstWhere((element) => element.name == map['type']),
      viewType: ComponentViewType.values.firstWhere((element) => element.name == map['viewType']),
      name: map['name'],
      state: map['state'],
      pos: offsetFromMap(map['pos']),
      size: sizeFromMap( map['size']),
    );
  }
}

DiscreteComponent createDiscreteComponent({
  required List<String> inputIds,
  required String outputId,
  required Offset pos,
  required String name,
  required DiscreteComponentType type,
  required ComponentViewType viewType,
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
    output: output,
    inputs: inputs,
    type: type,
    viewType: viewType,
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
    viewType: ComponentViewType.basicPart,
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
    viewType: ComponentViewType.basicPart,
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
    viewType: ComponentViewType.basicPart,
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
    viewType: ComponentViewType.basicPart,
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
    viewType: ComponentViewType.basicPart,
  );
}

DiscreteComponent createControlledComponent() {
  final ownId = const Uuid().v4();

  return createDiscreteComponent(
    inputIds: [],
    outputId: ownId,
    pos: Offset.zero,
    name: "In",
    type: DiscreteComponentType.controlled,
    viewType: ComponentViewType.controlledSwitch,
  );
}

DiscreteComponent createOutputComponent() {
  final inAId = const Uuid().v4();
  final ownId = const Uuid().v4();

  return createDiscreteComponent(
    inputIds: [inAId],
    outputId: ownId,
    pos: Offset.zero,
    name: "Out",
    type: DiscreteComponentType.output,
    viewType: ComponentViewType.bitOutput,
  );
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
    case DiscreteComponentType.output:
      return createOutputComponent();
  }
}
