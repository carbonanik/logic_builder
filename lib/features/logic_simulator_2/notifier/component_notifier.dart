import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:week_task/features/logic_simulator_2/models/discrete_component.dart';

class ComponentNotifier extends ChangeNotifier {
  final List<DiscreteComponent> _components = [];
  final Map<String, DiscreteComponent> _componentLookup = {};

  UnmodifiableListView<DiscreteComponent> get components => UnmodifiableListView(_components);
  UnmodifiableMapView<String, DiscreteComponent> get componentLookup => UnmodifiableMapView(_componentLookup);


  void addComponent(DiscreteComponent component){
    _components.add(component);
    _componentLookup[component.output.id] = component;
    notifyListeners();
  }
}
