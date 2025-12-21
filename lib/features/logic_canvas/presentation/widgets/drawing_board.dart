import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../painter/logic_painter.dart';
import '../../painter/mouse_position_painter.dart';
import '../../painter/wire_painter.dart';
import '../../provider/component_provider.dart';
import '../../provider/cursor_position_state_provider.dart';
import '../../provider/drawing_mode_provider.dart';
import '../../provider/event_handler_provider.dart';
import '../../provider/pan_offset_provider.dart';
import '../../provider/selected_component_provider.dart';
import '../../provider/wire_drawing_providers.dart';
import '../../provider/wires_provider.dart';
import '../mode.dart';

class DrawingBoard extends StatelessWidget {
  DrawingBoard({super.key});

  final keyboardFocusNode = FocusNode()..requestFocus();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer(
          builder: (context, ref, child) {
            final wireState = ref.watch(wiresProvider);
            final cursorPosition = ref.watch(cursorPositionProvider);
            final panOffset = ref.watch(panOffsetProvider);
            final drawingWire = ref.watch(isDrawingWire);

            return CustomPaint(
              painter: WirePainter(
                wires: wireState.wires,
                wiresLookup: wireState.wiresLookup,
                cursorPos: cursorPosition + panOffset,
                drawingWire: drawingWire,
                panOffset: panOffset,
              ),
              child: Container(),
            );
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            final componentState = ref.watch(componentsProvider);
            final cursorPosition = ref.watch(cursorPositionProvider);
            final panOffset = ref.watch(panOffsetProvider);
            return CustomPaint(
              painter: LogicPainter(
                components: componentState.components,
                componentLookup: componentState.componentLookup,
                cursorPos: cursorPosition + panOffset,
                panOffset: panOffset,
              ),
              child: Container(),
            );
          },
        ),
        if (!(defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android))
          Consumer(
            builder: (context, ref, child) {
              final cursorPosition = ref.watch(cursorPositionProvider);
              final panOffset = ref.watch(panOffsetProvider);
              final selectedComponent = ref.watch(selectedComponentProvider);
              final mode = ref.watch(drawingModeProvider);
              final wireState = ref.watch(wiresProvider);
              final drawingWire = ref.watch(isDrawingWire);

              return CustomPaint(
                painter: MousePositionPainter(
                  cursorPos: cursorPosition + panOffset,
                  selectedComponent: selectedComponent,
                  drawingComponent: mode == Mode.component,
                  panOffset: panOffset,
                  drawingWire: drawingWire,
                  wires: wireState.wires,
                ),
                child: Container(),
              );
            },
          ),
        Consumer(
          builder: (context, ref, child) {
            final eventHandler = ref.watch(eventHandlerProvider);
            return KeyboardListener(
              focusNode: keyboardFocusNode,
              onKeyEvent: eventHandler.handleOnKey,
              child: Listener(
                onPointerHover: eventHandler.handlePointerHover,
                child: GestureDetector(
                  onTapUp: eventHandler.handleOnTapDown,
                  onPanUpdate: eventHandler.handlePanUpdate,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
