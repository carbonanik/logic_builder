import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:week_task/features/logic_simulator/models/part.dart';
import 'package:week_task/features/logic_simulator/models/wire.dart';
import 'package:week_task/features/logic_simulator/painter/logic_painter.dart';

enum Mode {
  view,
  wire,
  component,
}

final reservedComponents = [
  Part.fromIoCount(
    2,
    1,
    const Offset(200, 200),
    "AND",
  ),
  Part.fromIoCount(
    2,
    1,
    const Offset(200, 300),
    "OR",
  ),
];

class LogicCanvasWidget extends StatefulWidget {
  const LogicCanvasWidget({super.key});

  @override
  State<LogicCanvasWidget> createState() => _LogicCanvasWidgetState();
}

class _LogicCanvasWidgetState extends State<LogicCanvasWidget> {
  Mode mode = Mode.view;
  List<Wire> wires = [];
  List<Part> components = [];
  Offset cursorPos = const Offset(0, 0);
  Offset? pointerOnIo;
  Wire? currentWire;
  bool drawingWire = false;
  bool straightLine = false;

  final keyboardFocusNode = FocusNode()..requestFocus();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RawKeyboardListener(
            focusNode: keyboardFocusNode,
            onKey: (value) {
              if (value is RawKeyDownEvent && value.data.physicalKey == PhysicalKeyboardKey.escape) {
                drawingWire = false;
                currentWire = null;
                setState(() {});
              } else if (value is RawKeyDownEvent && value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
                straightLine = true;
              } else if (value is RawKeyUpEvent && value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
                straightLine = false;
              }
            },
            child: Listener(
              onPointerHover: _handlePointerHover,
              child: GestureDetector(
                onTapDown: _handleOnTapDown,
                child: CustomPaint(
                  painter: LogicPainter(wires, components, cursorPos, drawingWire),
                  child: Container(),
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
                      mode = Mode.view;
                    } else {
                      mode = Mode.component;
                    }
                    setState(() {});
                  },
                  icon: const Icon(Icons.comment_bank),
                ),
                IconButton(
                  color: mode == Mode.wire ? Colors.blue : null,
                  onPressed: () {
                    if (mode == Mode.wire) {
                      mode = Mode.view;
                    } else {
                      mode = Mode.wire;
                    }
                    setState(() {});
                  },
                  icon: const Icon(Icons.line_axis),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handlePointerHover(PointerHoverEvent event) {
    if (currentWire != null) {
      cursorPos = getPoint(event.localPosition, currentWire!.last);
      drawingWire = true;
    } else {
      cursorPos = event.localPosition;
    }
    setState(() {});
  }

  void _handleOnTapDown(TapDownDetails details) {
    if (mode == Mode.wire) {
      _addWire(details.localPosition);
    } else if (mode == Mode.component) {
      _addComponent(details.localPosition);
    }
    setState(() {});
  }

  void _addComponent(Offset localPosition) {
    components.add(reservedComponents[0].copyWith(
      pos: localPosition,
    ));
  }

  void _addWire(Offset localPosition) {
    if (currentWire == null) {
      _addNewWire();
    } else {
      _addPointToCurrentWire(localPosition);
    }
  }

  _addNewWire() {
    for (var component in components) {
      for (var i = 0; i < component.input.length; i++) {
        final pos = component.input[i].pos + component.pos;
        final hovered = (pos - cursorPos).distance < 6;
        if (hovered) {
          currentWire = Wire(points: [pos]);
          wires.add(currentWire!);
        }
      }
      for (var i = 0; i < component.output.length; i++) {
        final pos = component.output[i].pos + component.pos;
        final hovered = (pos - cursorPos).distance < 6;
        if (hovered) {
          currentWire = Wire(points: [pos]);
          wires.add(currentWire!);
        }
      }
    }
  }

  _addPointToCurrentWire(Offset localPosition) {
    bool isHovered = false;
    Offset? iopos;
    for (var component in components) {
      for (var i = 0; i < component.input.length; i++) {
        final pos = component.input[i].pos + component.pos;
        isHovered = (pos - cursorPos).distance < 6;
        if (isHovered) {
          iopos = pos;
          break;
        }
      }
      for (var i = 0; i < component.output.length; i++) {
        if (isHovered) break;
        final pos = component.output[i].pos + component.pos;
        isHovered = (pos - cursorPos).distance < 6;
        if (isHovered) {
          iopos = pos;
          break;
        }
      }
      if (isHovered) {
        break;
      }
    }
    if (isHovered) {
      wires.last.addPoint(iopos!);
      drawingWire = false;
      currentWire = null;
    } else {
      wires.last.addPoint(getPoint(localPosition, currentWire!.last));
    }
  }

  Offset getPoint(Offset location, Offset lastPoint) {
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
