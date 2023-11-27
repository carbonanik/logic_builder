import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_grid/provider/open_module_id_provider.dart';
import 'package:logic_builder/features/logic_canvas/data_source/provider/module_provider.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component_type.dart';
import 'package:logic_builder/features/logic_canvas/models/module.dart';
import 'package:logic_builder/features/logic_canvas/painter/logic_painter.dart';
import 'package:logic_builder/features/logic_canvas/painter/mouse_position_painter.dart';
import 'package:logic_builder/features/logic_canvas/painter/wire_painter.dart';
import 'package:logic_builder/features/logic_canvas/provider/component_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/cursor_position_state_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/drawing_mode_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/event_handler_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/is_saved_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/pan_offset_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/selected_component_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/wire_drawing_providers.dart';
import 'package:logic_builder/features/logic_canvas/provider/wires_provider.dart';
import 'package:uuid/uuid.dart';

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

const selectionColor = Colors.redAccent;

class CanvasPage extends StatelessWidget {
  CanvasPage({super.key});

  final keyboardFocusNode = FocusNode()..requestFocus();
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
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
                  } else if (value is RawKeyDownEvent && value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
                    ref.read(isControlPressed.notifier).state = true;
                  } else if (value is RawKeyUpEvent && value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
                    ref.read(isControlPressed.notifier).state = false;
                  } else if (value is RawKeyUpEvent && value.physicalKey == PhysicalKeyboardKey.delete) {
                    eventHandler.handleDeleteKeypress();
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
              final selectedComponent = ref.watch(selectedComponentProvider);
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20, top: 10),
                  child: Column(
                    children: [
                      mode == Mode.component
                          ? CustomScrollbarWithSingleChildScrollView(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    reservedComponents.length,
                                    (index) => InkWell(
                                      onTap: () {
                                        ref.read(selectedComponentProvider.notifier).state = reservedComponents[index];
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        color: selectedComponent == reservedComponents[index]
                                            ? selectionColor
                                            : Colors.grey[800],
                                        child: Text(
                                          reservedComponents[index].name,
                                          style: TextStyle(
                                            color: selectedComponent == reservedComponents[index]
                                                ? Colors.grey[800]
                                                : Colors.grey[400],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              ref.read(drawingModeProvider.notifier).state = Mode.view;
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              color: mode == Mode.view ? selectionColor : Colors.grey[800],
                              child: Icon(
                                Icons.pan_tool_alt_rounded,
                                color: mode == Mode.view ? Colors.grey[800] : Colors.grey[400],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ref.read(drawingModeProvider.notifier).state = Mode.component;
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              color: mode == Mode.component ? selectionColor : Colors.grey[800],
                              child: Icon(
                                Icons.memory_rounded,
                                color: mode == Mode.component ? Colors.grey[800] : Colors.grey[400],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ref.read(drawingModeProvider.notifier).state = Mode.wire;
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              color: mode == Mode.wire ? selectionColor : Colors.grey[800],
                              child: Icon(
                                Icons.cable_rounded,
                                color: mode == Mode.wire ? Colors.grey[800] : Colors.grey[400],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final saved = ref.watch(isSavedProvider);
              print("saved => $saved");
              return Positioned(
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50, bottom: 20, top: 10),
                  child: InkWell(
                    onTap: () async {
                      final wires = ref.read(wiresProvider).wires;
                      final components = ref.read(componentsProvider).components;
                      final openModuleId = ref.read(openModuleIdProvider);
                      if (openModuleId == null) return;
                      final module = await ref.read(modulesStoreProvider).getModule(openModuleId);
                      if (module == null) return;
                      await ref.read(modulesStoreProvider).saveModule(
                            openModuleId,
                            module.copyWith(
                              wires: wires,
                              components: components,
                            ),
                          );
                      ref.read(isSavedProvider.notifier).state = true;
                      print("save");
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.grey[800],
                      child: Icon(
                        Icons.save,
                        color: saved ? Colors.grey[400] : selectionColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CustomScrollbarWithSingleChildScrollView extends StatelessWidget {
  final ScrollController controller;
  final Widget child;
  final Axis scrollDirection;

  const CustomScrollbarWithSingleChildScrollView({
    required this.controller,
    required this.child,
    required this.scrollDirection,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Scrollbar(
        controller: controller,
        child: SingleChildScrollView(
          controller: controller,
          scrollDirection: scrollDirection,
          child: child,
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
