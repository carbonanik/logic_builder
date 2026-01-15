import 'package:uuid/uuid.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component.dart';

class ComponentService {
  DiscreteComponent refreshComponentIds(DiscreteComponent component) {
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
}
