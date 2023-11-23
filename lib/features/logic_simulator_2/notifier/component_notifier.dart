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

  DiscreteComponent? isMousePointerOnComponent() {
    DiscreteComponent? component;
    final mousePos = _ref.read(cursorPositionProvider);
    for (var i = 0; i < components.length; i++) {
      component = components[i];
      final topLeft = component.pos;
      final bottomRight = component.pos + Offset(component.size.width, component.size.height);
      if (mousePos.dx >= topLeft.dx &&
          mousePos.dx <= bottomRight.dx &&
          mousePos.dy >= topLeft.dy &&
          mousePos.dy <= bottomRight.dy) return component;
    }
    return null;
  }

  void toggleControlled(){
    final component = isMousePointerOnComponent();
    if (component == null) return;
    if (component.type != DiscreteComponentType.controlled) return;
    final newComponent = component.copyWith(
      state: component.state == 1 ? 0 : 1,
    );

    _update(component, newComponent);
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
    _runLogics();
    notifyListeners();
  }

  void _runLogics() {
    const evalPerStep = 5;
    for (var j = 0; j < evalPerStep; j++) {
      _evaluate();
    }
    _components.clear();
    _components.addAll(_componentLookup.values);
  }

  void _evaluate() {
    DiscreteComponent binaryOp(int Function(int, int) logicFn, DiscreteComponent component) {
      final a = _componentLookup[component.inputs[0].id]?.state;
      final b = _componentLookup[component.inputs[1].id]?.state;
      return component.copyWith(state: logicFn(a ?? 0, b ?? 0));
    }

    for (var component in _components) {
      switch (component.type) {
        case DiscreteComponentType.output:
          final a = _componentLookup[component.inputs[0].id]?.state;
          _componentLookup[component.output.id] = component.copyWith(state: a ?? 0);
          break;
        case DiscreteComponentType.controlled:
          break;
        case DiscreteComponentType.and:
          _componentLookup[component.output.id] = binaryOp(and, component);
          break;
        case DiscreteComponentType.nand:
          _componentLookup[component.output.id] = binaryOp(nand, component);
          break;
        case DiscreteComponentType.or:
          _componentLookup[component.output.id] = binaryOp(or, component);
          break;
        case DiscreteComponentType.nor:
          _componentLookup[component.output.id] = binaryOp(nor, component);
          break;
        case DiscreteComponentType.not:
          final a = _componentLookup[component.inputs[0].id]?.state;
          _componentLookup[component.output.id] = component.copyWith(state: not(a ?? 0));
          break;
      }
    }
  }
}

int not(int a) => ~a & 1;

int and(int a, int b) => a & b;

int nand(int a, int b) => not(and(a, b));

int or(int a, int b) => a | b;

int nor(int a, int b) => not(or(a, b));
