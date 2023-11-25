import 'package:flutter/material.dart';
import 'package:logic_builder/models/wire.dart';

class WirePainter extends CustomPainter {
  final List<Wire> wires;
  final Map <String, Wire> wiresLookup;
  final Offset cursorPos;
  final bool drawingWire;
  final Offset panOffset;

  WirePainter({
    required this.wires,
    required this.wiresLookup,
    required this.cursorPos,
    required this.drawingWire,
    required this.panOffset,
  });

  final rectPaint = Paint()..style = PaintingStyle.fill;

  final inputPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.blue;

  final outputPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.red;

  final hoverIoPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.grey;

  final linePaint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    drawWires(canvas, size);
  }

  @override
  bool shouldRepaint(covariant WirePainter oldDelegate) {
    return true;
  }

  void drawWires(Canvas canvas, Size size) {
    for (int i = 0; i < wires.length; i++) {
      final wire = wires[i];
      final path = Path();

      final firstPoint = wire.first + panOffset;
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (int i = 1; i < wire.length - 1; i++) {
        final point = wire[i] + panOffset;
        final prevPoint = wire[i - 1] + panOffset;
        final nextPoint = wire[i + 1] + panOffset;
        if ((point - prevPoint).distance < 30 || (point - nextPoint).distance < 30) {
          path.lineTo(point.dx, point.dy);
        } else {
          path.roundCornerLineTo(point, prevPoint, nextPoint);
        }
      }

      final lastPoint = wire.last + panOffset;
      path.lineTo(lastPoint.dx, lastPoint.dy);
      canvas.drawPath(path, wire.paint);
      // if (path.contains(cursorPos)) {
      //   canvas.drawCircle(cursorPos, 10, wire.paint);
      // }
    }

    if (wires.isNotEmpty && wires.last.isNotEmpty && drawingWire) {
      canvas.drawLine(cursorPos, wires.last.last + panOffset, linePaint);
    }
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
