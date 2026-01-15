import 'package:logic_builder/features/logic_canvas/models/discrete_component.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component_type.dart';
import 'package:logic_builder/features/logic_canvas/models/module.dart';

class LogicSimulator {
  int and(int a, int b) => (a == 1 && b == 1) ? 1 : 0;
  int nand(int a, int b) => (a == 1 && b == 1) ? 0 : 1;
  int or(int a, int b) => (a == 1 || b == 1) ? 1 : 0;
  int nor(int a, int b) => (a == 1 || b == 1) ? 0 : 1;
  int not(int a) => a == 1 ? 0 : 1;

  void evaluate(
    List<DiscreteComponent> components,
    Map<String, DiscreteComponent> componentLookup,
    Map<String, Module> moduleCache,
    int globalClockState,
  ) {
    DiscreteComponent binaryOp(
        int Function(int, int) logicFn, DiscreteComponent component) {
      final a = componentLookup[component.inputs[0].id]
          ?.getState(component.inputs[0].id);
      final b = componentLookup[component.inputs[1].id]
          ?.getState(component.inputs[1].id);
      return component.copyWith(
        outputStates: {component.output.id: logicFn(a ?? 0, b ?? 0)},
      );
    }

    for (var component in components) {
      switch (component.type) {
        case DiscreteComponentType.output:
          final a = componentLookup[component.inputs[0].id]
              ?.getState(component.inputs[0].id);
          componentLookup[component.output.id] = component.copyWith(
            outputStates: {component.output.id: a ?? 0},
          );
          break;
        case DiscreteComponentType.controlled:
          break;
        case DiscreteComponentType.and:
          componentLookup[component.output.id] = binaryOp(and, component);
          break;
        case DiscreteComponentType.nand:
          componentLookup[component.output.id] = binaryOp(nand, component);
          break;
        case DiscreteComponentType.or:
          componentLookup[component.output.id] = binaryOp(or, component);
          break;
        case DiscreteComponentType.nor:
          componentLookup[component.output.id] = binaryOp(nor, component);
          break;
        case DiscreteComponentType.not:
          final a = componentLookup[component.inputs[0].id]
              ?.getState(component.inputs[0].id);
          componentLookup[component.output.id] = component.copyWith(
            outputStates: {component.output.id: not(a ?? 0)},
          );
          break;
        case DiscreteComponentType.module:
          evaluateModule(
              component, componentLookup, moduleCache, globalClockState);
          break;
        case DiscreteComponentType.clock:
          componentLookup[component.output.id] = component.copyWith(
            outputStates: {component.output.id: globalClockState},
          );
          break;
      }
    }
  }

  void evaluateModule(
    DiscreteComponent component,
    Map<String, DiscreteComponent> componentLookup,
    Map<String, Module> moduleCache,
    int globalClockState,
  ) {
    if (component.moduleId == null) return;
    final module = moduleCache[component.moduleId];
    if (module == null) return;

    final internalStates =
        Map<String, int>.from(component.internalStates ?? {});

    final inputComponents = module.components
        .where((c) => c.type == DiscreteComponentType.controlled)
        .toList();

    for (int i = 0; i < component.inputs.length; i++) {
      if (i >= inputComponents.length) break;
      final internalIOId = inputComponents[i].output.id;
      final externalInputState = componentLookup[component.inputs[i].id]
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
            // Nested module eval could be recursive here if needed
            break;
          case DiscreteComponentType.clock:
            newState = globalClockState;
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
      componentLookup[output.id] = newComponent;
    }
  }
}
