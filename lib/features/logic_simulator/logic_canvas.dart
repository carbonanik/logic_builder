import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:week_task/features/logic_simulator/models/component.dart';
import 'package:week_task/features/logic_simulator/models/wire.dart';
import 'package:week_task/features/logic_simulator/painter/logic_painter.dart';
import 'package:week_task/features/logic_simulator/painter/wire_painter.dart';

enum Mode {
  view,
  wire,
  component,
}

final reservedComponents = [
  createComponent(
    ["idInA", "idInB"],
    ["ownId"],
    Offset.zero,
    "AND",
  ),
  createComponent(
    ["idInA", "idInB"],
    ["ownId"],
    Offset.zero,
    "OR",
  ),
  createComponent(
    ["idIn"],
    ["ownId"],
    Offset.zero,
    "NOT",
  )
];

class LogicCanvasWidget extends StatefulWidget {
  const LogicCanvasWidget({super.key});

  @override
  State<LogicCanvasWidget> createState() => _LogicCanvasWidgetState();
}

class _LogicCanvasWidgetState extends State<LogicCanvasWidget> {
  Mode mode = Mode.view;
  List<Wire> wires = [];
  List<Component> components = []; //todo
  Offset cursorPos = const Offset(0, 0);
  Wire? currentWire;
  bool drawingWire = false;
  bool straightLine = false;
  Component? selectedComponent;
  Offset panOffset = const Offset(0, 0);

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
                onPanUpdate: (details) {
                  // print(details.delta);
                  panOffset += details.delta;
                  setState(() {});
                },
                child: CustomPaint(
                  painter: WirePainter(
                    wires: wires,
                    cursorPos: cursorPos + panOffset,
                    drawingWire: drawingWire,
                    panOffset: panOffset,
                  ),
                  child: CustomPaint(
                    painter: LogicPainter(
                      components: components,
                      cursorPos: cursorPos + panOffset,
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
    final localPosition = _excludePanOffset(event.localPosition);
    if (currentWire != null) {
      cursorPos = getPoint(localPosition, currentWire!.last);
      drawingWire = true;
    } else {
      cursorPos = localPosition;
    }
    setState(() {});
  }

  void _handleOnTapDown(TapDownDetails details) {
    final localPosition = _excludePanOffset(details.localPosition);
    if (mode == Mode.wire) {
      _addWire(localPosition);
    } else if (mode == Mode.component) {
      _addComponent(localPosition);
    }
    setState(() {});
  }

  Offset _excludePanOffset(Offset localPosition) {
    return localPosition - panOffset;
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
    if (ioPos == null) {
      return null;
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
