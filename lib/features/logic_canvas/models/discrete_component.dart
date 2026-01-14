import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logic_builder/features/logic_canvas/models/offset_map.dart';
import 'package:logic_builder/features/logic_canvas/models/size_map.dart';
import 'package:uuid/uuid.dart';
import 'package:logic_builder/features/logic_canvas/models/component_view_type.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component_type.dart';
import 'package:logic_builder/features/logic_canvas/models/io.dart';
import 'package:logic_builder/features/logic_canvas/models/module.dart';

class DiscreteComponent {
  final List<IO> outputs;
  final DiscreteComponentType type;
  final ComponentViewType viewType;
  final String name;
  final List<IO> inputs;
  final Map<String, int> outputStates;
  final Offset pos;
  final Size size;
  final String? moduleId;
  final Map<String, int>? internalStates;

  DiscreteComponent({
    required this.outputs,
    required this.inputs,
    required this.name,
    required this.type,
    required this.viewType,
    required this.outputStates,
    required this.pos,
    required this.size,
    this.moduleId,
    this.internalStates,
  });

  IO get output => outputs.first;
  int get state =>
      outputStates.values.isNotEmpty ? outputStates.values.first : 0;
  int getState(String ioId) => outputStates[ioId] ?? 0;

  DiscreteComponent copyWith({
    List<IO>? outputs,
    DiscreteComponentType? type,
    ComponentViewType? viewType,
    String? name,
    List<IO>? inputs,
    Map<String, int>? outputStates,
    Offset? pos,
    Size? size,
    String? moduleId,
    Map<String, int>? internalStates,
  }) {
    return DiscreteComponent(
      outputs: outputs ?? this.outputs,
      type: type ?? this.type,
      viewType: viewType ?? this.viewType,
      name: name ?? this.name,
      inputs: inputs ?? this.inputs,
      outputStates: outputStates ?? this.outputStates,
      pos: pos ?? this.pos,
      size: size ?? this.size,
      moduleId: moduleId ?? this.moduleId,
      internalStates: internalStates ?? this.internalStates,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'outputs': outputs.map((e) => e.toMap()).toList(),
      'inputs': inputs.map((e) => e.toMap()).toList(),
      'type': type.name,
      'viewType': viewType.name,
      'name': name,
      'outputStates': outputStates,
      'pos': pos.toMap(),
      'size': size.toMap(),
      'moduleId': moduleId,
      'internalStates': internalStates,
    };
  }

  factory DiscreteComponent.fromMap(Map<String, dynamic> map) {
    return DiscreteComponent(
      outputs: map['outputs'] != null
          ? (map['outputs'] as List).map((e) => IO.fromMap(e)).toList()
          : [IO.fromMap(map['output'])],
      inputs: (map['inputs'] as List).map((e) => IO.fromMap(e)).toList(),
      type: DiscreteComponentType.values
          .firstWhere((element) => element.name == map['type']),
      viewType: ComponentViewType.values
          .firstWhere((element) => element.name == map['viewType']),
      name: map['name'],
      outputStates: map['outputStates'] != null
          ? Map<String, int>.from(map['outputStates'])
          : {
              ((map['outputs'] as List?)?.first['id'] ?? map['output']['id']):
                  map['state'] ?? 0
            },
      pos: offsetFromMap(map['pos']),
      size: sizeFromMap(map['size']),
      moduleId: map['moduleId'],
      internalStates: map['internalStates'] != null
          ? Map<String, int>.from(map['internalStates'])
          : null,
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
  final double height =
      _calculateHeight(inputIds.isEmpty ? 1 : inputIds.length);
  final double width = _calculateWidth(name);
  final size = Size(width, height);
  final inputs = generateIOs(inputIds, 0, size.height);
  final output = IO(
    id: outputId,
    name: "out",
    pos: Offset(width, size.height / 2),
  );

  return DiscreteComponent(
    outputs: [output],
    inputs: inputs,
    type: type,
    viewType: viewType,
    name: name,
    pos: pos,
    size: size,
    outputStates: {outputId: 0},
  );
}

DiscreteComponent createComposedComponent({
  required Module module,
  required Offset pos,
}) {
  // Find controlled components for inputs
  final inputComponents = module.components
      .where((c) => c.type == DiscreteComponentType.controlled)
      .toList();
  // Find output components for outputs
  final outputComponents = module.components
      .where((c) => c.type == DiscreteComponentType.output)
      .toList();

  final size =
      measureSize(inputComponents.length, outputComponents.length, module.name);

  final inputs = generateIOs(
      inputComponents.map((c) => c.output.id).toList(), 0, size.height);

  // Custom generateIOs for outputs on the right side
  final outputs = List.generate(
    outputComponents.length,
    (index) => IO(
      id: outputComponents[index].output.id,
      name: outputComponents[index].name,
      pos: Offset(
          size.width,
          _calculateHeight(index) +
              (size.height - _calculateHeight(outputComponents.length)) / 2),
    ),
  );

  return DiscreteComponent(
    outputs: outputs,
    inputs: inputs,
    type: DiscreteComponentType.module,
    viewType: ComponentViewType.basicPart, // Or a new one
    name: module.name,
    pos: pos,
    size: size,
    outputStates: {for (var o in outputs) o.id: 0},
    moduleId: module.id,
    internalStates: {},
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

DiscreteComponent createClockComponent() {
  final ownId = const Uuid().v4();

  return createDiscreteComponent(
    inputIds: [],
    outputId: ownId,
    pos: Offset.zero,
    name: "Clock",
    type: DiscreteComponentType.clock,
    viewType: ComponentViewType
        .controlledSwitch, // Using switch view for simplicity for now
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
    case DiscreteComponentType.module:
      throw UnimplementedError(
          "Module component creation requires a Module object");
    case DiscreteComponentType.clock:
      return createClockComponent();
  }
}
