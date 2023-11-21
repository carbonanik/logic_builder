import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/logic_simulator_2/event_handlers.dart';
import 'package:week_task/features/logic_simulator_2/models/pair.dart';
import 'package:week_task/features/logic_simulator_2/models/wire.dart';
import 'package:week_task/features/logic_simulator_2/painter/logic_painter.dart';
import 'package:week_task/features/logic_simulator_2/painter/wire_painter.dart';
import 'package:week_task/features/logic_simulator_2/provider/component_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/cursor_position_state_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/drawing_mode_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/event_handler_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/pan_offset_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/selected_component_provider.dart';
import 'package:week_task/features/logic_simulator_2/provider/wire_drawing_providers.dart';
import 'package:week_task/features/logic_simulator_2/provider/wires_provider.dart';
import 'models/discrete_component.dart';

enum Mode {
  view,
  wire,
  component,
}

final reservedComponents = [
  createComponent(DiscreteComponentType.and),
  createComponent(DiscreteComponentType.or),
  createComponent(DiscreteComponentType.not),
];

class LogicCanvasWidget2 extends StatefulWidget {
  const LogicCanvasWidget2({super.key});

  @override
  State<LogicCanvasWidget2> createState() => _LogicCanvasWidgetState();
}

class _LogicCanvasWidgetState extends State<LogicCanvasWidget2> {

  final keyboardFocusNode = FocusNode()..requestFocus();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final componentState = ref.watch(componentsProvider);
          final wireState = ref.watch(wiresProvider);
          final cursorPosition = ref.watch(cursorPositionProvider);
          final panOffset = ref.watch(panOffsetProvider);
          final drawingWire = ref.watch(isDrawingWire);
          final selectedComponent = ref.watch(selectedComponentProvider);
          final mode = ref.watch(drawingModeProvider);
          final currentWireConnectionID = ref.watch(currentDrawingWireIdProvider);
          final eventHandler = ref.watch(eventHandlerProvider);
          return Stack(
            children: [
              RawKeyboardListener(
                focusNode: keyboardFocusNode,
                onKey: (value) {
                  if (value is RawKeyDownEvent && value.data.physicalKey == PhysicalKeyboardKey.escape) {
                    eventHandler.wireDrawingEnd();
                    ref.read(selectedComponentProvider.notifier).state = null;
                    setState(() {});
                  } else if (value is RawKeyDownEvent && value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
                    ref.read(isControlPressed.notifier).state = true;
                  } else if (value is RawKeyUpEvent && value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
                    // straightLine = false;
                    ref.read(isControlPressed.notifier).state = false;
                  }
                },
                child: Listener(
                  onPointerHover: eventHandler.handlePointerHover,
                  child: GestureDetector(
                    onTapDown: eventHandler.handleOnTapDown,
                    onPanUpdate: (details) {
                      // print(details.delta);
                      // panOffset += details.delta;
                      ref.read(panOffsetProvider.notifier).state += details.delta;
                      setState(() {});
                    },
                    child: CustomPaint(
                      painter: WirePainter(
                        wires: wireState.wires,
                        wiresLookup: wireState.wiresLookup,
                        cursorPos: cursorPosition + panOffset,
                        drawingWire: drawingWire,
                        panOffset: panOffset,
                      ),
                      child: CustomPaint(
                        painter: LogicPainter(
                          components: componentState.components,
                          componentLookup: componentState.componentLookup,
                          cursorPos: cursorPosition + panOffset,
                          selectedComponent: selectedComponent,
                          drawingComponent: mode == Mode.component,
                          panOffset: panOffset,
                        ),
                        child: Container(),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 50,
                bottom: 50,
                child: Row(
                  children: [
                    IconButton(
                      color: mode == Mode.component ? Colors.blue : null,
                      onPressed: () {
                        if (mode == Mode.component) {
                          ref.read(drawingModeProvider.notifier).state = Mode.view;
                          // mode = Mode.view;
                        } else {
                          ref.read(drawingModeProvider.notifier).state = Mode.component;
                          // mode = Mode.component;
                        }
                        setState(() {});
                      },
                      icon: const Icon(Icons.comment_bank),
                    ),
                    IconButton(
                      color: mode == Mode.wire ? Colors.blue : null,
                      onPressed: () {
                        if (mode == Mode.wire) {
                          // mode = Mode.view;
                          ref.read(drawingModeProvider.notifier).state = Mode.view;
                        } else {
                          // mode = Mode.wire;
                          ref.read(drawingModeProvider.notifier).state = Mode.wire;
                        }
                        setState(() {});
                      },
                      icon: const Icon(Icons.line_axis),
                    ),
                  ],
                ),
              ),
              if (mode == Mode.component)
                Positioned(
                  left: 50,
                  bottom: 100,
                  child: Row(
                    children: List.generate(
                      reservedComponents.length,
                      (index) => ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            selectedComponent == reservedComponents[index] ? Colors.blue : null,
                          ),
                        ),
                        onPressed: () {
                          // selectedComponent = reservedComponents[index];
                          ref.read(selectedComponentProvider.notifier).state = reservedComponents[index];
                          setState(() {});
                        },
                        child: Text(
                          reservedComponents[index].name,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}

class MatchedIoData {
  final Offset globalPos;
  final String ioId;
  final String componentId;

  MatchedIoData(
    this.globalPos,
    this.ioId,
    this.componentId,
  );
}
