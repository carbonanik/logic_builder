import 'package:flutter/gestures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/logic_simulator_2/canvas_page.dart';
import 'package:week_task/features/logic_simulator_2/provider/component_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/cursor_position_state_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/drawing_mode_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/pan_offset_provider.dart';
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
      ref.read(isDrawingWire.notifier).state = true;
    } else {
      ref.read(cursorPositionProvider.notifier).state = localPosition;
    }
  }

  void handleOnTapDown(TapDownDetails details) {
    final mode = ref.read(drawingModeProvider);
    final localPosition = _excludePanOffset(details.localPosition);
    if (mode == Mode.view) {
      ref.read(componentsProvider.notifier).toggleControlled();
    } else if (mode == Mode.wire) {
      ref.read(wiresProvider.notifier).addWire(localPosition);
    } else if (mode == Mode.component) {
      ref.read(componentsProvider).addComponent(localPosition);
    }
  }

  Offset _excludePanOffset(Offset localPosition) {
    final panOffset = ref.read(panOffsetProvider);
    return localPosition - panOffset;
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

  void wireDrawingEnd() {
    ref.read(isDrawingWire.notifier).state = false;
    ref.read(currentDrawingWireIdProvider.notifier).state = null;
  }

  void wireDiscard() {
    final currentWire = ref.read(currentWireProvider);
    ref.read(isDrawingWire.notifier).state = false;
    ref.read(currentDrawingWireIdProvider.notifier).state = null;
    if (currentWire == null) return;
    ref.read(wiresProvider).removeWire(currentWire);
  }
}
