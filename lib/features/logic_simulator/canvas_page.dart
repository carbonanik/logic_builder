import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/logic_simulator/models/discrete_component_type.dart';
import 'package:week_task/features/logic_simulator/painter/logic_painter.dart';
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
          final componentState = ref.watch(componentsProvider);
          final wireState = ref.watch(wiresProvider);
          final cursorPosition = ref.watch(cursorPositionProvider);
          final panOffset = ref.watch(panOffsetProvider);
          final drawingWire = ref.watch(isDrawingWire);
          final selectedComponent = ref.watch(selectedComponentProvider);
          final mode = ref.watch(drawingModeProvider);
          final eventHandler = ref.watch(eventHandlerProvider);
          return Stack(
            children: [
              RawKeyboardListener(
                focusNode: keyboardFocusNode,
                onKey: (value) {
                  if (value is RawKeyDownEvent && value.data.physicalKey == PhysicalKeyboardKey.escape) {
                    eventHandler.wireDiscard();
                    ref.read(selectedComponentProvider.notifier).state = null;
                  } else if (value is RawKeyDownEvent && value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
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
                      color: mode == Mode.view ? Colors.blue : null,
                      onPressed: () {
                          ref.read(drawingModeProvider.notifier).state = Mode.view;
                      },
                      icon: const Icon(Icons.view_cozy),
                    ),
                    IconButton(
                      color: mode == Mode.component ? Colors.blue : null,
                      onPressed: () {
                          ref.read(drawingModeProvider.notifier).state = Mode.component;
                      },
                      icon: const Icon(Icons.comment_bank),
                    ),
                    IconButton(
                      color: mode == Mode.wire ? Colors.blue : null,
                      onPressed: () {
                          ref.read(drawingModeProvider.notifier).state = Mode.wire;
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
                          ref.read(selectedComponentProvider.notifier).state = reservedComponents[index];
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


