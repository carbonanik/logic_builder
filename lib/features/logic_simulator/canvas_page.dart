import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/logic_simulator/models/discrete_component_type.dart';
import 'package:week_task/features/logic_simulator/painter/logic_painter.dart';
import 'package:week_task/features/logic_simulator/painter/mouse_position_painter.dart';
import 'package:week_task/features/logic_simulator/painter/wire_painter.dart';
import 'package:week_task/features/logic_simulator/provider/component_provider.dart';
import 'package:week_task/features/logic_simulator/provider/cursor_position_state_provider.dart';
import 'package:week_task/features/logic_simulator/provider/drawing_mode_provider.dart';
import 'package:week_task/features/logic_simulator/provider/event_handler_provider.dart';
import 'package:week_task/features/logic_simulator/provider/pan_offset_provider.dart';
import 'package:week_task/features/logic_simulator/provider/selected_component_provider.dart';
import 'package:week_task/features/logic_simulator/provider/wire_drawing_providers.dart';
import 'package:week_task/features/logic_simulator/provider/wires_provider.dart';
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
  createComponent(DiscreteComponentType.nand),
  createComponent(DiscreteComponentType.nor),
  createComponent(DiscreteComponentType.controlled),
  createComponent(DiscreteComponentType.output),
];

const selectionColor = Colors.purpleAccent;

class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key});

  @override
  State<CanvasPage> createState() => _LogicCanvasWidgetState();
}

class _LogicCanvasWidgetState extends State<CanvasPage> {
  final keyboardFocusNode = FocusNode()..requestFocus();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
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
              Consumer(
                builder: (context, ref, child) {
                  final cursorPosition = ref.watch(cursorPositionProvider);
                  final panOffset = ref.watch(panOffsetProvider);
                  final selectedComponent = ref.watch(selectedComponentProvider);
                  final mode = ref.watch(drawingModeProvider);
                  return CustomPaint(
                    painter: MousePositionPainter(
                      cursorPos: cursorPosition + panOffset,
                      selectedComponent: selectedComponent,
                      drawingComponent: mode == Mode.component,
                    ),
                    child: Container(),
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final eventHandler = ref.watch(eventHandlerProvider);
                  return RawKeyboardListener(
                    focusNode: keyboardFocusNode,
                    onKey: (value) {
                      if (value is RawKeyDownEvent && value.data.physicalKey == PhysicalKeyboardKey.escape) {
                        eventHandler.wireDiscard();
                        ref.read(selectedComponentProvider.notifier).state = null;
                      } else if (value is RawKeyDownEvent &&
                          value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
                        ref.read(isControlPressed.notifier).state = true;
                      } else if (value is RawKeyUpEvent && value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
                        ref.read(isControlPressed.notifier).state = false;
                      }
                    },
                    child: Listener(
                      onPointerHover: eventHandler.handlePointerHover,
                      child: GestureDetector(
                        onTapDown: eventHandler.handleOnTapDown,
                        onPanUpdate: (details) {
                          ref.read(panOffsetProvider.notifier).state += details.delta;
                        },
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final mode = ref.watch(drawingModeProvider);
                  return Positioned(
                    left: 50,
                    right: 50,
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          color: mode == Mode.view ? selectionColor : null,
                          onPressed: () {
                            ref.read(drawingModeProvider.notifier).state = Mode.view;
                          },
                          icon: const Icon(Icons.pan_tool_alt_rounded),
                        ),
                        IconButton(
                          color: mode == Mode.component ? selectionColor : null,
                          onPressed: () {
                            ref.read(drawingModeProvider.notifier).state = Mode.component;
                          },
                          icon: const Icon(Icons.memory_rounded),
                        ),
                        IconButton(
                          color: mode == Mode.wire ? selectionColor : null,
                          onPressed: () {
                            ref.read(drawingModeProvider.notifier).state = Mode.wire;
                          },
                          icon: const Icon(Icons.cable_rounded),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final mode = ref.watch(drawingModeProvider);
                  final selectedComponent = ref.watch(selectedComponentProvider);
                  return mode == Mode.component
                      ? Positioned(
                          left: 50,
                          right: 50,
                          bottom: 70,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              reservedComponents.length,
                              (index) => ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      selectedComponent == reservedComponents[index] ? Colors.deepPurple : null,
                                    ),
                                    foregroundColor: MaterialStateProperty.all(
                                      selectedComponent == reservedComponents[index] ? Colors.white : null,
                                    )),
                                onPressed: () {
                                  ref.read(selectedComponentProvider.notifier).state = reservedComponents[index];
                                },
                                child: Text(
                                  reservedComponents[index].name,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox();
                },
              )
            ],
          );
        },
      ),
    );
  }
}
