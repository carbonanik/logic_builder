import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:week_task/utils/log.dart';

class LogicCanvasWidget extends StatefulWidget {
  const LogicCanvasWidget({super.key});

  @override
  State<LogicCanvasWidget> createState() => _LogicCanvasWidgetState();
}

class _LogicCanvasWidgetState extends State<LogicCanvasWidget> {
  List<Wire> wires = [];
  Offset? cursorPos;
  Wire? currentWire;

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
                currentWire = null;
                cursorPos = null;
                setState(() {});
              } else if (value is RawKeyDownEvent && value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
                straightLine = true;
                "[CTRL] Down".log();
              } else if (value is RawKeyUpEvent && value.data.physicalKey == PhysicalKeyboardKey.controlLeft) {
                straightLine = false;
                "[CTRL] Up".log();
              }
            },
            child: Listener(
              onPointerHover: _handlePointerHover,
              child: GestureDetector(
                onTapDown: _handleOnTapDown,
                child: CustomPaint(
                  painter: MindMapPainter(wires, cursorPos),
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
                  onPressed: () {},
                  icon: const Icon(Icons.comment_bank),
                ),
                IconButton(
                  onPressed: () {},
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
    if (currentWire == null) return;
    cursorPos = getPoint(event.localPosition, currentWire!.last);
    setState(() {});
  }

  void _handleOnTapDown(TapDownDetails details) {
    "[CLICK]".log();
    if (currentWire == null) {
      currentWire = Wire(points: [details.localPosition]);
      wires.add(currentWire!);
    } else {
      wires.last.addPoint(getPoint(details.localPosition, currentWire!.last));
    }
    setState(() {});
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
      return Offset(
        location.dx,
        lastPoint.dy,
      );
    } else {
      return Offset(
        lastPoint.dx,
        location.dy,
      );
    }
  }
}

// =======================================================================

class Wire {
  final List<Offset> _points;
  final Color color;
  final double width;
  final Paint paint;

  bool isCompleted = true;

  Wire({
    List<Offset> points = const [],
    this.color = Colors.brown,
    this.width = 3,
  })  : _points = points,
        paint = Paint()
          ..color = color
          ..strokeWidth = width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  addPoint(Offset point) {
    _points.add(point);
  }

  complete() {
    isCompleted = true;
  }

  get last => _points.last;

  get first => _points.first;

  get length => _points.length;

  get isNotEmpty => _points.isNotEmpty;

  get isEmpty => _points.isEmpty;

  operator [](int index) {
    return _points[index];
  }
}

// =======================================================================

class MindMapPainter extends CustomPainter {
  final List<Wire> wires;
  final Offset? cursorPos;

  MindMapPainter(this.wires, this.cursorPos);

  final rectPaint = Paint()..style = PaintingStyle.fill;

  final linePaint = Paint()
    ..color = Colors.brown
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    // drawBackground(canvas, size);
    drawWires(canvas, size);
    // drawComponent(canvas, Offset(size.width / 2, size.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawComponent(Canvas canvas, Offset offset) {
    canvas.drawRect(
      Rect.fromPoints(
        const Offset(0, 0) + offset,
        const Offset(80, 30) + offset,
      ),
      linePaint..color = Colors.blue,
    );
  }

  void drawWires(Canvas canvas, Size size) {
    for (int i = 0; i < wires.length; i++) {
      final wire = wires[i];
      final path = Path();

      path.moveTo(wire.first.dx, wire.first.dy);

      for (int i = 1; i < wire.length - 1; i++) {
        final point = wire[i];
        final prevPoint = wire[i - 1];
        final nextPoint = wire[i + 1];

        path.roundCornerLineTo(point, prevPoint, nextPoint);
      }
      // if (wires.isNotEmpty && wires.last.isNotEmpty && cursorPos != null) {
      //   final point = wire[wire.length - 1];
      //   final prevPoint = wire[wire.length - 2];
      //   final nextPoint = cursorPos!;
      //   path.roundCornerLineTo(point, prevPoint, nextPoint);
      //   path.lineTo(nextPoint.dx, nextPoint.dy);
      // }
      // if (wires.isNotEmpty && wires.last.isNotEmpty && cursorPos != null) {
      // } else {
        path.lineTo(wire.last.dx, wire.last.dy);
      // }
      canvas.drawPath(path, wire.paint);
    }
    // if (wires.isNotEmpty && wires.last.isNotEmpty && cursorPos != null) {
    //   final path = Path();
    //   final point = wires.last[wires.last.length - 1];
    //   final prevPoint = wires.last[wires.last.length - 2];
    //   final nextPoint = cursorPos!;
    //
    //   final prp = getRoundPoint(point, prevPoint);
    //   final nrp = getRoundPoint(point, nextPoint);
    //
    //   path.moveTo(prp.dx, prp.dy);
    //   path.quadraticBezierTo(point.dx, point.dy, nrp.dx, nrp.dy);
    //   path.lineTo(nextPoint.dx, nextPoint.dy);
    //
    //   canvas.drawPath(path, wires.last.paint);
    // }
    if (wires.isNotEmpty && wires.last.isNotEmpty && cursorPos != null) {
      canvas.drawLine(cursorPos!, wires.last.last, wires.last.paint);
    }
  }

  void drawBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    rectPaint.shader = const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Colors.deepPurple,
        Colors.purple,
      ],
    ).createShader(rect);

    canvas.drawRect(rect, rectPaint);
  }
}

Offset getRoundPoint(Offset point, Offset? toPoint) {
  if (toPoint == null) return point;
  return (toPoint - point).normalized() * 20 + point;
}

extension XPath on Path {
  roundCornerLineTo(Offset point, Offset prevPoint, Offset nextPoint) {
    final prp = getRoundPoint(point, prevPoint);
    final nrp = getRoundPoint(point, nextPoint);

    lineTo(prp.dx, prp.dy);
    quadraticBezierTo(point.dx, point.dy, nrp.dx, nrp.dy);
  }
}

extension XOffset on Offset {
  Offset normalized() {
    return this / distance;
  }
}
