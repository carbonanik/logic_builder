import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_grid/provider/open_module_id_provider.dart';
import 'package:logic_builder/features/logic_canvas/data_source/provider/module_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/is_saved_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component_type.dart';
import 'package:logic_builder/features/logic_canvas/models/io.dart';
import 'package:logic_builder/features/logic_canvas/models/matched_io.dart';
import 'package:logic_builder/features/logic_canvas/provider/cursor_position_state_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/selected_component_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/wires_provider.dart';

class ComponentNotifier extends ChangeNotifier {
  final Ref _ref;

  ComponentNotifier(this._ref) {
    final openModuleId = _ref.read(openModuleIdProvider);
    if (openModuleId == null) return;
    _ref.read(modulesStoreProvider).getModule(openModuleId).then((value) {
      value?.components.forEach((component) {
        _components.add(component);
        _componentLookup[component.output.id] = component;
      });
      notifyListeners();
      _ref.read(isSavedProvider.notifier).state = true;
    });
  }

  final List<DiscreteComponent> _components = [];
  final Map<String, DiscreteComponent> _componentLookup = {};

  UnmodifiableListView<DiscreteComponent> get components => UnmodifiableListView(_components);

  UnmodifiableMapView<String, DiscreteComponent> get componentLookup => UnmodifiableMapView(_componentLookup);

  void changeComponentInputId(String componentId, String ioId, String replacedIoId) {
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

  void removeWireIDFromComponentIO(String componentId, String wireId) {
    final component = _componentLookup[componentId];
    final inputs = component?.inputs;
    for (var i = 0; i < (inputs?.length ?? 0); i++) {
      if (inputs?[i].connectedWireIds?.contains(wireId) == true) {
        inputs![i] = inputs[i].copyWith(
          connectedWireIds: inputs[i].connectedWireIds!.where((element) => element != wireId).toList(),
          id: const Uuid().v4(),
          // new id because inputs id get replaced by connected component output id by changing it we are disconnecting it
        );
      }
    }
    var output = component?.output;
    if (output?.connectedWireIds?.contains(wireId) == true) {
      output = output?.copyWith(
        connectedWireIds: output.connectedWireIds!.where((element) => element != wireId).toList(),
      );
    }
    final newComponent = component?.copyWith(inputs: inputs, output: output);
    _update(component!, newComponent!);
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

  void toggleControlled() {
    final component = isMousePointerOnComponent();
    if (component == null) return;
    if (component.type != DiscreteComponentType.controlled) return;
    final newComponent = component.copyWith(
      state: component.state == 1 ? 0 : 1,
    );

    _update(component, newComponent);
  }

  bool deleteMouseOverComponent() {
    final component = isMousePointerOnComponent();
    if (component == null) return false;
    final ios = component.inputs + [component.output];
    final wiresIds = <String>{};
    for (var element in ios) {
      wiresIds.addAll(element.connectedWireIds ?? []);
    }
    _ref.read(wiresProvider).removeWires(wiresIds.toList());

    _delete(componentLookup[component.output.id]!);
    return true;
  }

  void connectIOToWire(String componentId, String ioId, String wireId) {
    final component = _componentLookup[componentId];
    if (component == null) return;
    final inputs = component.inputs;
    for (var i = 0; i < component.inputs.length; i++) {
      if (component.inputs[i].id == ioId) {
        inputs[i] = inputs[i].copyWith(connectedWireIds: (inputs[i].connectedWireIds ?? [])..add(wireId));
      }
    }
    var output = component.output;
    if (output.id == ioId) {
      output = output.copyWith(connectedWireIds: (output.connectedWireIds ?? [])..add(wireId));
    }
    final newComponent = component.copyWith(inputs: inputs, output: output);
    _update(component, newComponent);
  }

  MatchedIoData? _matchedIO(List<IO> ios, Offset componentPos) {
    final cursorPos = _ref.read(cursorPositionProvider);
    for (var i = 0; i < ios.length; i++) {
      final globalPos = ios[i].pos + componentPos;
      final isHovered = (globalPos - cursorPos).distance < 10; // TODO this was 6

      if (isHovered) {
        return MatchedIoData(
          ioId: ios[i].id,
          globalPos: globalPos,
          componentId: '',
          startFromInput: true,
          matchedIO: ios[i].copyWith(),
        );
      }
    }
    return null;
  }

  void _add(DiscreteComponent component) {
    _components.add(component);
    _componentLookup[component.output.id] = component;
    _onChange();
    _ref.read(isSavedProvider.notifier).state = false;
  }

  void _update(DiscreteComponent component, DiscreteComponent newComponent) {
    _components[_components.indexOf(component)] = newComponent;
    _componentLookup[component.output.id] = newComponent;
    _onChange();
  }

  void _delete(DiscreteComponent component) {
    _components.remove(component);
    _componentLookup.remove(component.output.id);
    _onChange();
    _ref.read(isSavedProvider.notifier).state = false;
  }

  void _onChange() {
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
