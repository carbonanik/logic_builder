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

  void _add(DiscreteComponent component) {
    _components.add(component);
    _componentLookup[component.output.id] = component;
    notifyListeners();
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
      ioData = _matchedIO(component.inputs, component.pos);
      if (ioData != null) break;
      ioData = _matchedIO([component.output], component.pos);
      if (ioData != null) break;
    }
    if (ioData == null) {
      return null;
    }
    return ioData;
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
        );
      }
    }
    return null;
  }
}
