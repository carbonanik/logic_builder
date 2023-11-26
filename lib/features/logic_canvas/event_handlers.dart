import 'package:flutter/gestures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_canvas/canvas_page.dart';
import 'package:logic_builder/features/logic_canvas/provider/component_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/cursor_position_state_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/drawing_mode_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/pan_offset_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/wire_drawing_providers.dart';
import 'package:logic_builder/features/logic_canvas/provider/wires_provider.dart';

class EventsHandler {
  final Ref _ref;

  EventsHandler(this._ref);

  void handlePointerHover(PointerHoverEvent event) {
    final currentWireID = _ref.read(currentDrawingWireIdProvider);
    final localPosition = _excludePanOffset(event.localPosition);
    if (currentWireID != null) {
      final currentWire = _ref.read(currentWireProvider)!;
      final cursorPos = getPoint(localPosition, currentWire.last);
      _ref.read(cursorPositionProvider.notifier).state = cursorPos;
      _ref.read(isDrawingWire.notifier).state = true;
    } else {
      _ref.read(cursorPositionProvider.notifier).state = localPosition;
    }
  }

  void handleOnTapDown(TapDownDetails details) {
    final mode = _ref.read(drawingModeProvider);
    final localPosition = _excludePanOffset(details.localPosition);
    if (mode == Mode.view) {
      _ref.read(componentsProvider.notifier).toggleControlled();
    } else if (mode == Mode.wire) {
      _ref.read(wiresProvider.notifier).addWire(localPosition);
    } else if (mode == Mode.component) {
      _ref.read(componentsProvider).addComponent(localPosition);
    }
  }

  Offset _excludePanOffset(Offset localPosition) {
    final panOffset = _ref.read(panOffsetProvider);
    return localPosition - panOffset;
  }

  Offset getPoint(Offset location, Offset lastPoint) {
    final straightLine = _ref.read(isControlPressed);
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

  void wireDrawingEnd() {
    _ref.read(isDrawingWire.notifier).state = false;
    _ref.read(currentDrawingWireIdProvider.notifier).state = null;
  }

  void wireDiscard() {
    final currentWire = _ref.read(currentWireProvider);
    _ref.read(isDrawingWire.notifier).state = false;
    _ref.read(currentDrawingWireIdProvider.notifier).state = null;
    if (currentWire == null) return;
    _ref.read(wiresProvider).removeWire(currentWire.id);
  }

  void handleDeleteKeypress() {
    final deleted = _ref.read(wiresProvider).deleteMouseOverWire();
    print(deleted);
    if (deleted) return;
    _ref.read(componentsProvider).deleteMouseOverComponent();
  }
}
