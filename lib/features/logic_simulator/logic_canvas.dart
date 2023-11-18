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
    Offset.zero,
    "AND",
  ),
  Part.fromIoCount(
    2,
    1,
    Offset.zero,
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
  Part? selectedComponent;

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
                _wireDrawingEnd();
                selectedComponent = null;
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
                  painter: LogicPainter(
                    wires: wires,
                    components: components,
                    cursorPos: cursorPos,
                    drawingWire: drawingWire,
                    selectedComponent: selectedComponent,
                    drawingComponent: mode == Mode.component,
                  ),
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
                      selectedComponent = reservedComponents[index];
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
    if (selectedComponent == null) {
      return;
    }
    components.add(
      selectedComponent!.copyWith(
        pos: localPosition,
      ),
    );
  }

  void _addWire(Offset localPosition) {
    if (currentWire == null) {
      _addNewWire();
    } else {
      _addPointToCurrentWire(localPosition);
    }
  }

  void _addNewWire() {
    final ioPos = _isMousePointerOnIO();
    if (ioPos != null) {
      currentWire = Wire(points: [ioPos]);
      wires.add(currentWire!);
    }
  }

  void _addPointToCurrentWire(Offset localPosition) {
    final Offset? ioPos = _isMousePointerOnIO();
    if (ioPos != null) {
      wires.last.addPoint(ioPos);
      _wireDrawingEnd();
    } else {
      wires.last.addPoint(getPoint(localPosition, currentWire!.last));
    }
  }

  void _wireDrawingEnd() {
    drawingWire = false;
    currentWire = null;
  }

  Offset? _isMousePointerOnIO() {
    Offset? ioPos;
    for (var component in components) {
      ioPos = _matchedIO(component.input, component.pos);
      if (ioPos != null) break;
      ioPos = _matchedIO(component.output, component.pos);
      if (ioPos != null) break;
    }
    return ioPos;
  }

  Offset? _matchedIO(List<IO> ios, Offset componentPos) {
    for (var i = 0; i < ios.length; i++) {
      final pos = ios[i].pos + componentPos;
      final isHovered = (pos - cursorPos).distance < 6;
      if (isHovered) {
        return pos;
      }
    }
    return null;
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
