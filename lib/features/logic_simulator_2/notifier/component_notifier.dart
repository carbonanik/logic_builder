import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/logic_simulator_2/models/discrete_component.dart';
import 'package:week_task/features/logic_simulator_2/models/matched_io.dart';
import 'package:week_task/features/logic_simulator_2/models/pair.dart';
import 'package:week_task/features/logic_simulator_2/provider/component_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/cursor_position_state_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/selected_component_provider.dart';

class ComponentNotifier extends ChangeNotifier {
  final Ref _ref;

  ComponentNotifier(this._ref);

  final List<DiscreteComponent> _components = [];
  final Map<String, DiscreteComponent> _componentLookup = {};

  UnmodifiableListView<DiscreteComponent> get components => UnmodifiableListView(_components);

  UnmodifiableMapView<String, DiscreteComponent> get componentLookup => UnmodifiableMapView(_componentLookup);

  void replaceInputIo(String componentId, String ioId, String replacedIoId) {
    final component = _componentLookup[componentId];
    if (component == null) return;
    final inputs = component.inputs;
    for (var i = 0; i < component.inputs.length; i++) {
      if (inputs[i].id == ioId) {
        inputs[i] = inputs[i].copyWith(id: replacedIoId);
      }
    }
    final newComponent = component.copyWith(inputs: inputs);
    _update(component, newComponent);
  }

  void addComponent(Offset localPosition) {
    final selectedComponent = _ref.read(selectedComponentProvider);
    if (selectedComponent == null) return;

    final comp = createComponent(
      selectedComponent.type,
    ).copyWith(
      pos: localPosition,
    );
    _add(comp);
  }

  MatchedIoData? isMousePointerOnIO() {
    MatchedIoData? ioData;
    for (var component in components) {
      ioData = _matchedIO(component.inputs, component.pos)?.copyWith(
        componentId: component.output.id,
        startFromInput: true,
      );
      if (ioData != null) break;
      ioData = _matchedIO([component.output], component.pos)?.copyWith(
        componentId: component.output.id,
        startFromInput: false,
      );

      if (ioData != null) break;
    }
    return ioData;
  }

  MatchedIoData? _matchedIO(List<IO> ios, Offset componentPos) {
    final cursorPos = _ref.read(cursorPositionProvider);
    for (var i = 0; i < ios.length; i++) {
      final globalPos = ios[i].pos + componentPos;
      final isHovered = (globalPos - cursorPos).distance < 6;

      if (isHovered) {
        return MatchedIoData(
          ioId: ios[i].id,
          globalPos: globalPos,
          componentId: '',
          startFromInput: true,
        );
      }
    }
    return null;
  }

  void _add(DiscreteComponent component) {
    _components.add(component);
    _componentLookup[component.output.id] = component;
    _noChange();
  }

  void _update(DiscreteComponent component, DiscreteComponent newComponent) {
    _components[_components.indexOf(component)] = newComponent;
    _componentLookup[component.output.id] = newComponent;
    _noChange();
  }

  void _noChange() {
    // _runLogics();
    notifyListeners();
  }

  // void _runLogics() {
  //   const evalPerStep = 5;
  //   for (var j = 0; j < evalPerStep; j++) {
      // evaluate(componentLookup);
  //   }
  // }
}

// evaluate(Map<String, DiscreteComponent> componentsMap) {
//   DiscreteComponent binaryOp(int Function(int, int) logicFn, DiscreteComponent component) {
//     final a = componentsMap[component.inputs[0]]?.state;
//     final b = componentsMap[component.inputs[1]]?.state;
//     return component.copyWith(state: logicFn(a ?? 0, b ?? 0));
//   }

  // for (var component in componentsMap.values) {
  //   switch (component.type) {
  //     case DiscreteComponentType.controlled:
  //       break;
  //     case DiscreteComponentType.and:
  //       componentsMap[component.output.id] = binaryOp(and, component);
  //       break;
  //     case DiscreteComponentType.nand:
  //       componentsMap[component.output.id] = binaryOp(nand, component);
  //       break;
  //     case DiscreteComponentType.or:
  //       componentsMap[component.output.id] = binaryOp(or, component);
  //       break;
  //     case DiscreteComponentType.nor:
  //       componentsMap[component.output.id] = binaryOp(nor, component);
  //       break;
  //     case DiscreteComponentType.not:
  //       final a = componentsMap[component.inputs[0]]?.state;
  //       componentsMap[component.output.id] = component.copyWith(state: not(a ?? 0));
  //       break;
  //   }
  // }
// }

// int not(int a) => ~a & 1;
//
// int and(int a, int b) => a & b;
//
// int nand(int a, int b) => not(and(a, b));
//
// int or(int a, int b) => a | b;
//
// int nor(int a, int b) => not(or(a, b));
