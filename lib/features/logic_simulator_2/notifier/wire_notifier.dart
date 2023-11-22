import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/logic_simulator_2/models/pair.dart';
import 'package:week_task/features/logic_simulator_2/models/wire.dart';
import 'package:week_task/features/logic_simulator_2/provider/component_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/event_handler_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/wire_drawing_providers.dart';

class WireNotifier extends ChangeNotifier {
  final Ref _ref;

  WireNotifier(this._ref);

  final List<Wire> _wires = [];
  final Map<String, Wire> _wiresLookup = {};

  UnmodifiableListView<Wire> get wires => UnmodifiableListView(_wires);

  UnmodifiableMapView<String, Wire> get wiresLookup => UnmodifiableMapView(_wiresLookup);

  void _add(Wire wire) {
    _wires.add(wire);
    _wiresLookup[wire.connectionId] = wire;
    notifyListeners();
  }

  void addWire(Offset localPosition) {
    final currentWireConnectionID = _ref.read(currentDrawingWireIdProvider);
    if (currentWireConnectionID == null) {
      _addNewWire();
    } else {
      _addPointToCurrentWire(localPosition);
    }
  }

  void _addNewWire() {
    final ioData = _ref.read(componentsProvider).isMousePointerOnIO();
    if (ioData == null) return;
    // currentWireConnectionID = ioData.a;
    _ref.read(currentDrawingWireIdProvider.notifier).state = ioData.a;
    // wires[currentWireConnectionID!] = Wire(points: [ioData.b], connectionId: currentWireConnectionID!);
    _add(
      Wire(
        points: [ioData.b],
        connectionId: ioData.a,
      ),
    );
  }

  void _addPointToCurrentWire(Offset localPosition) {
    final currentWire = _wiresLookup[_ref.read(currentDrawingWireIdProvider)];
    if (currentWire == null) return;

    final Pair<String, Offset>? ioData = _ref.read(componentsProvider).isMousePointerOnIO();
    if (ioData != null) {
      currentWire.addPoint(ioData.b);
      _ref.read(eventHandlerProvider).wireDrawingEnd();
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