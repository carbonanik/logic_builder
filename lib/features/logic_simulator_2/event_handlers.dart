import 'package:flutter/gestures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/logic_simulator_2/logic_canvas.dart';
import 'package:week_task/features/logic_simulator_2/models/discrete_component.dart';
import 'package:week_task/features/logic_simulator_2/models/pair.dart';
import 'package:week_task/features/logic_simulator_2/models/wire.dart';
import 'package:week_task/features/logic_simulator_2/provider/component_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/cursor_position_state_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/drawing_mode_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/pan_offset_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/selected_component_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/wire_drawing_providers.dart';
import 'package:week_task/features/logic_simulator_2/provider/wires_provider.dart';

class EventsHandler {
  final Ref ref;

  EventsHandler(this.ref);

  void handlePointerHover(PointerHoverEvent event) {
    final currentWireID = ref.read(currentDrawingWireIdProvider);
    final localPosition = _excludePanOffset(event.localPosition);
    if (currentWireID != null) {
      final currentWire = ref.read(currentWireProvider)!;
      final cursorPos = getPoint(localPosition, currentWire.last);
      ref.read(cursorPositionProvider.notifier).state = cursorPos;
      // drawingWire = true;
      ref.read(isDrawingWire.notifier).state = true;
    } else {
      // cursorPos = localPosition;
      ref.read(cursorPositionProvider.notifier).state = localPosition;
    }
  }

  void handleOnTapDown(TapDownDetails details) {
    final mode = ref.read(drawingModeProvider);
    final localPosition = _excludePanOffset(details.localPosition);
    if (mode == Mode.wire) {
      _addWire(localPosition);
    } else if (mode == Mode.component) {
      _addComponent(localPosition);
    }
  }

  Offset _excludePanOffset(Offset localPosition) {
    final panOffset = ref.read(panOffsetProvider);
    return localPosition - panOffset;
  }

  void _addComponent(Offset localPosition) {
    final selectedComponent = ref.read(selectedComponentProvider);
    if (selectedComponent == null) return;

    final comp = createComponent(
      selectedComponent.type,
    ).copyWith(
      pos: localPosition,
    );
    // wires[comp.output.id] = comp;
    ref.read(componentsProvider.notifier).addComponent(comp);
  }

  void _addWire(Offset localPosition) {
    final currentWireConnectionID = ref.read(currentDrawingWireIdProvider);
    if (currentWireConnectionID == null) {
      _addNewWire();
    } else {
      _addPointToCurrentWire(localPosition);
    }
  }

  void _addNewWire() {
    final ioData = _isMousePointerOnIO();
    if (ioData == null) return;
    // currentWireConnectionID = ioData.a;
    ref.read(currentDrawingWireIdProvider.notifier).state = ioData.a;
    // wires[currentWireConnectionID!] = Wire(points: [ioData.b], connectionId: currentWireConnectionID!);
    ref.read(wiresProvider.notifier).addWire(Wire(points: [ioData.b], connectionId: ioData.a));
  }

  void _addPointToCurrentWire(Offset localPosition) {
    final currentWire = ref.read(currentWireProvider);
    if (currentWire == null) return;

    final Pair<String, Offset>? ioData = _isMousePointerOnIO();
    if (ioData != null) {
      currentWire.addPoint(ioData.b);
      wireDrawingEnd();
    } else {
      currentWire.addPoint(getPoint(localPosition, currentWire.last));
    }
  }

  Pair<String, Offset>? _isMousePointerOnIO() {
    final components = ref.read(componentsProvider).components;
    Pair<String, Offset>? ioData;
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

  void wireDrawingEnd() {
    // drawingWire = false;
    ref.read(isDrawingWire.notifier).state = false;
    // currentWireConnectionID = null;
    ref.read(currentDrawingWireIdProvider.notifier).state = null;
  }

  Pair<String, Offset>? _matchedIO(List<IO> ios, Offset componentPos) {
    final cursorPos = ref.read(cursorPositionProvider);
    for (var i = 0; i < ios.length; i++) {
      final pos = ios[i].pos + componentPos;
      final isHovered = (pos - cursorPos).distance < 6;

      if (isHovered) {
        return Pair(ios[i].id, pos);
      }
    }
    return null;
  }

  Offset getPoint(Offset location, Offset lastPoint) {
    final straightLine = ref.read(isControlPressed);
    if (straightLine) {
      return getStraitPoint(location, lastPoint);
    } else {
      return location;
    }
  }

  Offset getStraitPoint(Offset location, Offset lastPoint) {
    final cDistance = lastPoint - location;

    if (cDistance.dx.abs() > cDistance.dy.abs()) {
      return Offset(location.dx, lastPoint.dy);
    } else {
      return Offset(lastPoint.dx, location.dy);
    }
  }
}
