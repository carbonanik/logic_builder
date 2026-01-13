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
import 'package:logic_builder/features/logic_canvas/models/module.dart';
import 'package:logic_builder/features/logic_canvas/provider/cursor_position_state_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/selected_component_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/wires_provider.dart';

class ComponentNotifier extends ChangeNotifier {
  final Ref _ref;

  ComponentNotifier(this._ref) {
    final openModuleId = _ref.read(openModuleIdProvider);
    if (openModuleId == null) return;
    _loadModuleAndDependencies(openModuleId).then((_) {
      _ref.read(isSavedProvider.notifier).state = true;
      notifyListeners();
    });
  }

  final Map<String, Module> _moduleCache = {};

  Future<void> _loadModuleAndDependencies(String moduleId) async {
    final module = await _ref.read(modulesStoreProvider).getModule(moduleId);
    if (module == null) return;
    _moduleCache[moduleId] = module;

    if (moduleId == _ref.read(openModuleIdProvider)) {
      _components.clear();
      _componentLookup.clear();
      for (var component in module.components) {
        _components.add(component);
        for (var output in component.outputs) {
          _componentLookup[output.id] = component;
        }
      }
    }

    for (var component in module.components) {
      if (component.type == DiscreteComponentType.module &&
          component.moduleId != null) {
        if (!_moduleCache.containsKey(component.moduleId)) {
          await _loadModuleAndDependencies(component.moduleId!);
        }
      }
    }
  }

  final List<DiscreteComponent> _components = [];
  final Map<String, DiscreteComponent> _componentLookup = {};

  UnmodifiableListView<DiscreteComponent> get components =>
      UnmodifiableListView(_components);

  UnmodifiableMapView<String, DiscreteComponent> get componentLookup =>
      UnmodifiableMapView(_componentLookup);

  void changeComponentInputId(
      String componentId, String ioId, String replacedIoId) {
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

    DiscreteComponent comp;
    if (selectedComponent.type == DiscreteComponentType.module) {
      comp =
          _refreshComponentIds(selectedComponent).copyWith(pos: localPosition);
    } else {
      comp =
          createComponent(selectedComponent.type).copyWith(pos: localPosition);
    }
    _add(comp);
  }

  DiscreteComponent _refreshComponentIds(DiscreteComponent component) {
    final idMap = <String, String>{};

    final newInputs = component.inputs.map((io) {
      final newId = const Uuid().v4();
      idMap[io.id] = newId;
      return io.copyWith(id: newId, connectedWireIds: []);
    }).toList();

    final newOutputs = component.outputs.map((io) {
      final newId = const Uuid().v4();
      idMap[io.id] = newId;
      return io.copyWith(id: newId, connectedWireIds: []);
    }).toList();

    final newOutputStates = <String, int>{};
    for (var entry in component.outputStates.entries) {
      if (idMap.containsKey(entry.key)) {
        newOutputStates[idMap[entry.key]!] = entry.value;
      } else {
        newOutputStates[entry.key] = entry.value;
      }
    }

    return component.copyWith(
      inputs: newInputs,
      outputs: newOutputs,
      outputStates: newOutputStates,
    );
  }

  void removeWireIDFromComponentIO(String componentId, String wireId) {
    final component = _componentLookup[componentId];
    final inputs = component?.inputs;
    for (var i = 0; i < (inputs?.length ?? 0); i++) {
      if (inputs?[i].connectedWireIds?.contains(wireId) == true) {
        inputs![i] = inputs[i].copyWith(
          connectedWireIds: inputs[i]
              .connectedWireIds!
              .where((element) => element != wireId)
              .toList(),
          id: const Uuid().v4(),
          // new id because inputs id get replaced by connected component output id by changing it we are disconnecting it
        );
      }
    }
    final outputs = List<IO>.from(component?.outputs ?? []);
    for (var i = 0; i < outputs.length; i++) {
      if (outputs[i].connectedWireIds?.contains(wireId) == true) {
        outputs[i] = outputs[i].copyWith(
          connectedWireIds: outputs[i]
              .connectedWireIds!
              .where((element) => element != wireId)
              .toList(),
        );
      }
    }
    final newComponent = component?.copyWith(inputs: inputs, outputs: outputs);
    _update(component!, newComponent!);
  }

  MatchedIoData? isMousePointerOnIO() {
    MatchedIoData? ioData;
    for (var component in components) {
      ioData = _matchedIO(component.inputs, component.pos)?.copyWith(
        componentId: component
            .outputs.first.id, // Using first output ID as component ID ref
        startFromInput: true,
      );
      if (ioData != null) break;
      ioData = _matchedIO(component.outputs, component.pos)?.copyWith(
        componentId: component.outputs.first.id,
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
      final bottomRight =
          component.pos + Offset(component.size.width, component.size.height);
      if (mousePos.dx >= topLeft.dx &&
          mousePos.dx <= bottomRight.dx &&
          mousePos.dy >= topLeft.dy &&
          mousePos.dy <= bottomRight.dy) {
        return component;
      }
    }
    return null;
  }

  void toggleControlled() {
    final component = isMousePointerOnComponent();
    if (component == null) return;
    if (component.type != DiscreteComponentType.controlled) return;
    final newComponent = component.copyWith(
      outputStates: {component.outputs.first.id: component.state == 1 ? 0 : 1},
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
        inputs[i] = inputs[i].copyWith(
            connectedWireIds: (inputs[i].connectedWireIds ?? [])..add(wireId));
      }
    }
    final outputs = List<IO>.from(component.outputs);
    for (var i = 0; i < outputs.length; i++) {
      if (outputs[i].id == ioId) {
        outputs[i] = outputs[i].copyWith(
            connectedWireIds: (outputs[i].connectedWireIds ?? [])..add(wireId));
      }
    }
    final newComponent = component.copyWith(inputs: inputs, outputs: outputs);
    _update(component, newComponent);
  }

  MatchedIoData? _matchedIO(List<IO> ios, Offset componentPos) {
    final cursorPos = _ref.read(cursorPositionProvider);
    for (var i = 0; i < ios.length; i++) {
      final globalPos = ios[i].pos + componentPos;
      final isHovered = (globalPos - cursorPos).distance < 10;

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
    for (var output in component.outputs) {
      _componentLookup[output.id] = component;
    }
    if (component.type == DiscreteComponentType.module &&
        component.moduleId != null) {
      _loadModuleAndDependencies(component.moduleId!).then((_) => _onChange());
    } else {
      _onChange();
    }
    _ref.read(isSavedProvider.notifier).state = false;
  }

  void _update(DiscreteComponent component, DiscreteComponent newComponent) {
    _components[_components.indexOf(component)] = newComponent;
    for (var output in component.outputs) {
      _componentLookup.remove(output.id);
    }
    for (var output in newComponent.outputs) {
      _componentLookup[output.id] = newComponent;
    }
    _onChange();
  }

  void _delete(DiscreteComponent component) {
    _components.remove(component);
    for (var output in component.outputs) {
      _componentLookup.remove(output.id);
    }
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
    DiscreteComponent binaryOp(
        int Function(int, int) logicFn, DiscreteComponent component) {
      final a = _componentLookup[component.inputs[0].id]
          ?.getState(component.inputs[0].id);
      final b = _componentLookup[component.inputs[1].id]
          ?.getState(component.inputs[1].id);
      return component.copyWith(
        outputStates: {component.output.id: logicFn(a ?? 0, b ?? 0)},
      );
    }

    for (var component in _components) {
      switch (component.type) {
        case DiscreteComponentType.output:
          final a = _componentLookup[component.inputs[0].id]
              ?.getState(component.inputs[0].id);
          _componentLookup[component.output.id] = component.copyWith(
            outputStates: {component.output.id: a ?? 0},
          );
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
          final a = _componentLookup[component.inputs[0].id]
              ?.getState(component.inputs[0].id);
          _componentLookup[component.output.id] = component.copyWith(
            outputStates: {component.output.id: not(a ?? 0)},
          );
          break;
        case DiscreteComponentType.module:
          _evaluateModule(component);
          break;
      }
    }
  }

  void _evaluateModule(DiscreteComponent component) {
    if (component.moduleId == null) return;
    final module = _moduleCache[component.moduleId];
    if (module == null) return;

    final internalStates =
        Map<String, int>.from(component.internalStates ?? {});

    final inputComponents = module.components
        .where((c) => c.type == DiscreteComponentType.controlled)
        .toList();

    for (int i = 0; i < component.inputs.length; i++) {
      if (i >= inputComponents.length) break;
      final internalIOId = inputComponents[i].output.id;
      final externalInputState = _componentLookup[component.inputs[i].id]
              ?.getState(component.inputs[i].id) ??
          0;
      internalStates[internalIOId] = externalInputState;
    }

    const internalEvalSteps = 3;
    for (int step = 0; step < internalEvalSteps; step++) {
      for (var innerComp in module.components) {
        if (innerComp.type == DiscreteComponentType.controlled) continue;

        int newState = 0;
        switch (innerComp.type) {
          case DiscreteComponentType.output:
            newState = internalStates[innerComp.inputs[0].id] ?? 0;
            break;
          case DiscreteComponentType.and:
            newState = and(internalStates[innerComp.inputs[0].id] ?? 0,
                internalStates[innerComp.inputs[1].id] ?? 0);
            break;
          case DiscreteComponentType.nand:
            newState = nand(internalStates[innerComp.inputs[0].id] ?? 0,
                internalStates[innerComp.inputs[1].id] ?? 0);
            break;
          case DiscreteComponentType.or:
            newState = or(internalStates[innerComp.inputs[0].id] ?? 0,
                internalStates[innerComp.inputs[1].id] ?? 0);
            break;
          case DiscreteComponentType.nor:
            newState = nor(internalStates[innerComp.inputs[0].id] ?? 0,
                internalStates[innerComp.inputs[1].id] ?? 0);
            break;
          case DiscreteComponentType.not:
            newState = not(internalStates[innerComp.inputs[0].id] ?? 0);
            break;
          case DiscreteComponentType.controlled:
            break;
          case DiscreteComponentType.module:
            // This would require pre-evaluating sub-modules or more complex logic
            // For now, let's assume one level of module nesting works
            break;
        }
        internalStates[innerComp.output.id] = newState;
      }
    }

    final outputComponents = module.components
        .where((c) => c.type == DiscreteComponentType.output)
        .toList();

    final newOutputStates = <String, int>{};
    for (int i = 0; i < component.outputs.length; i++) {
      if (i >= outputComponents.length) break;
      final internalOutputState =
          internalStates[outputComponents[i].output.id] ?? 0;
      newOutputStates[component.outputs[i].id] = internalOutputState;
    }

    final newComponent = component.copyWith(
      outputStates: newOutputStates,
      internalStates: internalStates,
    );

    for (var output in newComponent.outputs) {
      _componentLookup[output.id] = newComponent;
    }
  }
}

int not(int a) => ~a & 1;

int and(int a, int b) => a & b;

int nand(int a, int b) => not(and(a, b));

int or(int a, int b) => a | b;

int nor(int a, int b) => not(or(a, b));
