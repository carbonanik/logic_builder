import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:week_task/features/logic_simulator_2/models/discrete_component.dart';
import 'package:week_task/features/logic_simulator_2/models/wire.dart';

class WireNotifier extends ChangeNotifier {
  final List<Wire> _wires = [];
  final Map<String, Wire> _wiresLookup = {};

  UnmodifiableListView<Wire> get wires => UnmodifiableListView(_wires);

  UnmodifiableMapView<String, Wire> get wiresLookup => UnmodifiableMapView(_wiresLookup);

  void addWire(Wire wire){
    _wires.add(wire);
    _wiresLookup[wire.connectionId] = wire;
    notifyListeners();
  }
}
