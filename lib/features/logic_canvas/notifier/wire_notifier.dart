import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_grid/provider/open_module_id_provider.dart';
import 'package:logic_builder/features/logic_canvas/data_source/provider/module_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/is_saved_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:logic_builder/features/logic_canvas/models/matched_io.dart';
import 'package:logic_builder/features/logic_canvas/models/wire.dart';
import 'package:logic_builder/features/logic_canvas/provider/component_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/event_handler_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/wire_drawing_providers.dart';

class WireNotifier extends ChangeNotifier {
  final Ref _ref;

  WireNotifier(this._ref) {
    final openModuleId = _ref.read(openModuleIdProvider);
    if (openModuleId == null) return;
    _ref.read(modulesStoreProvider).getModule(openModuleId).then((value) {
      value?.wires.forEach((wire) {
        _wires.add(wire);
        _wiresLookup[wire.id] = wire;
      });
      notifyListeners();
      _ref.read(isSavedProvider.notifier).state = true;
    });
  }

  final List<Wire> _wires = [];
  final Map<String, Wire> _wiresLookup = {};

  UnmodifiableListView<Wire> get wires => UnmodifiableListView(_wires);

  UnmodifiableMapView<String, Wire> get wiresLookup => UnmodifiableMapView(_wiresLookup);

  void _add(Wire wire) {
    _wires.add(wire);
    _wiresLookup[wire.id] = wire;
    _onChange();
    _ref.read(isSavedProvider.notifier).state = false;
  }

  void _remove(Wire wire) {
    _wires.remove(wire);
    _wiresLookup.remove(wire.id);
    _onChange();
    _ref.read(isSavedProvider.notifier).state = false;
  }

  void _update(Wire wire, Wire newWire) {
    _wires[_wires.indexOf(wire)] = newWire;
    _wiresLookup[wire.id] = newWire;
    _onChange();
  }

  void addWire(Offset localPosition) {
    final currentWireConnectionID = _ref.read(currentDrawingWireIdProvider);
    if (currentWireConnectionID == null) {
      _addNewWire();
    } else {
      _addPointToCurrentWire(localPosition);
    }
  }

  void removeWire(String wireId) {
    if (_wiresLookup.containsKey(wireId)) {
      final wire = _wiresLookup[wireId]!;
      _ref.read(componentsProvider).removeWireIDFromComponentIO(wire.startComponentId, wireId);
      if (wire.endComponentId?.isNotEmpty == true) {
        _ref.read(componentsProvider).removeWireIDFromComponentIO(wire.endComponentId!, wireId);
      }
      _remove(_wiresLookup[wireId]!);
    }
  }

  void _addNewWire() {
    final ioData = _ref.read(componentsProvider).isMousePointerOnIO();
    if (ioData == null) return;

    // do not add wire if the input is already connected
    if (ioData.startFromInput) {
      if (_ref.read(componentsProvider).componentLookup[ioData.ioId] != null) return;
    }
    final id = const Uuid().v4();
    _ref.read(currentDrawingWireIdProvider.notifier).state = id;
    _add(
      Wire(
        id: id,
        points: [ioData.globalPos],
        connectionId: ioData.ioId,
        startComponentId: ioData.componentId,
        startFromInput: ioData.startFromInput,
      ),
    );

    // store wire id in the io
    _ref.read(componentsProvider).connectIOToWire(ioData.componentId, ioData.ioId, id);
  }

  void _addPointToCurrentWire(Offset localPosition) {
    final currentWire = _wiresLookup[_ref.read(currentDrawingWireIdProvider)];
    if (currentWire == null) return;

    // get io data that is clicked
    final MatchedIoData? ioData = _ref.read(componentsProvider).isMousePointerOnIO();
    // is clicked on IO ? if it is maybe the wire ends

    if (ioData != null) {
      // do not add point if started and ended from the only input or output
      if (ioData.startFromInput == currentWire.startFromInput) return;

      // replace io id
      if (currentWire.startFromInput) {
        // started from input ending at output
        final componentId = currentWire.startComponentId;
        final ioId = currentWire.connectionId;
        final replacedIoId = ioData.ioId;

        // ending the wire
        currentWire.addPoint(ioData.globalPos);
        _ref.read(eventHandlerProvider).wireDrawingEnd();

        // store wire id in the io
        _ref.read(componentsProvider).connectIOToWire(ioData.componentId, ioData.ioId, currentWire.id);

        // replace the id with the output id that is connected
        _ref.read(componentsProvider).changeComponentInputId(componentId, ioId, replacedIoId);

        wireEndComponent(currentWire.id, ioData.componentId);
      } else {
        // started from output ending at input
        // already have a wire connected to the input
        if (_ref.read(componentsProvider).componentLookup[ioData.ioId] != null) return;
        final componentId = ioData.componentId;
        final ioId = ioData.ioId;
        final replacedIoId = currentWire.connectionId;

        // ending the wire
        currentWire.addPoint(ioData.globalPos);
        _ref.read(eventHandlerProvider).wireDrawingEnd();

        // store wire id in the io
        _ref.read(componentsProvider).connectIOToWire(ioData.componentId, ioData.ioId, currentWire.id);

        _ref.read(componentsProvider).changeComponentInputId(componentId, ioId, replacedIoId);

        wireEndComponent(currentWire.id, ioData.componentId);
      }
    } else {
      currentWire.addPoint(
        _ref.read(eventHandlerProvider).getPoint(
              localPosition,
              currentWire.last,
            ),
      );
    }
  }

  void wireEndComponent(String wireID, String componentId) {
    final wire = _wiresLookup[wireID];
    if (wire == null) return;
    final newWire = wire.copyWith(
      endComponentId: componentId,
    );

    _update(wire, newWire);
  }

  void removeWires(List<String> ids) {
    for (var id in ids) {
      removeWire(id);
    }
  }

  bool deleteMouseOverWire() {
    final ioData = _ref.read(componentsProvider).isMousePointerOnIO();
    if (ioData == null) return false;
    removeWires(ioData.matchedIO.connectedWireIds ?? []);
    return true;
  }

  void _onChange() {
    notifyListeners();
  }
}
