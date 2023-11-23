import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:week_task/features/logic_simulator/models/matched_io.dart';
import 'package:week_task/features/logic_simulator/models/pair.dart';
import 'package:week_task/features/logic_simulator/models/wire.dart';
import 'package:week_task/features/logic_simulator/provider/component_provider.dart';
import 'package:week_task/features/logic_simulator/provider/event_handler_provider.dart';
import 'package:week_task/features/logic_simulator/provider/wire_drawing_providers.dart';

class WireNotifier extends ChangeNotifier {
  final Ref _ref;

  WireNotifier(this._ref);

  final List<Wire> _wires = [];
  final Map<String, Wire> _wiresLookup = {};

  UnmodifiableListView<Wire> get wires => UnmodifiableListView(_wires);

  UnmodifiableMapView<String, Wire> get wiresLookup => UnmodifiableMapView(_wiresLookup);

  void _add(Wire wire) {
    _wires.add(wire);
    _wiresLookup[wire.id] = wire;
    // notifyListeners();
  }

  void addWire(Offset localPosition) {
    final currentWireConnectionID = _ref.read(currentDrawingWireIdProvider);
    if (currentWireConnectionID == null) {
      _addNewWire();
    } else {
      _addPointToCurrentWire(localPosition);
    }
    notifyListeners();
  }

  void removeWire(Wire wire) {
    _wires.remove(wire);
    _wiresLookup.remove(wire.id);
    notifyListeners();
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

        _ref.read(componentsProvider).replaceInputIo(componentId, ioId, replacedIoId);
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

        _ref.read(componentsProvider).replaceInputIo(componentId, ioId, replacedIoId);
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
}
