import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:week_task/features/logic_simulator/models/part.dart';
import 'package:week_task/features/logic_simulator/models/wire.dart';

class WirePainter extends CustomPainter {
  final List<Wire> wires;
  final List<Part> components;
  final Offset cursorPos;
  final bool drawingWire;

  final Part? selectedComponent;
  final bool drawingComponent;

  WirePainter({
    required this.wires,
    required this.components,
    required this.cursorPos,
    required this.drawingWire,
    required this.selectedComponent,
    required this.drawingComponent,
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
    // drawBackground(canvas, size);
    drawCurrentComponent(canvas, size);
    drawWires(canvas, size);
    drawComponent(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawCurrentComponent(Canvas canvas, Size size) {
    if (selectedComponent != null && drawingComponent) {
      canvas.drawRect(
        Rect.fromPoints(
          const Offset(0, 0) + cursorPos,
          Offset(selectedComponent!.size.width, selectedComponent!.size.height) + cursorPos,
        ),
        rectPaint,
      );

      const textStyle = TextStyle(
        color: Colors.redAccent,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );
      final textSpan = TextSpan(
        text: selectedComponent!.name,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: selectedComponent!.size.width,
      );
      textPainter.paint(
        canvas,
        Offset(
              18,
              selectedComponent!.size.height / 2 - 12,
            ) +
            cursorPos,
      );
    }
  }

  void drawComponent(Canvas canvas, Size size) {
    for (int i = 0; i < components.length; i++) {
      final component = components[i];

      canvas.drawRect(
        Rect.fromPoints(
          const Offset(0, 0) + component.pos,
          Offset(component.size.width, component.size.height) + component.pos,
        ),
        rectPaint,
      );

      for (int i = 0; i < component.input.length; i++) {
        final pos = component.input[i].pos + component.pos;
        final hovered = (pos - cursorPos).distance < 6;
        if (hovered) {
          canvas.drawCircle(
            pos,
            8,
            hoverIoPaint,
          );
        }
        canvas.drawCircle(
          pos,
          6,
          inputPaint,
        );
      }

      for (int i = 0; i < component.output.length; i++) {
        final pos = component.output[i].pos + component.pos;
        final hovered = (pos - cursorPos).distance < 6;
        if (hovered) {
          canvas.drawCircle(
            pos,
            8,
            hoverIoPaint,
          );
        }
        canvas.drawCircle(
          pos,
          6,
          outputPaint,
        );
      }

      const textStyle = TextStyle(
        color: Colors.redAccent,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );
      final textSpan = TextSpan(
        text: component.name,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: component.size.width,
      );
      textPainter.paint(canvas, component.pos + Offset(18, component.size.height / 2 - 12));
    }
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
        if ((point - prevPoint).distance < 30 || (point - nextPoint).distance < 30) {
          path.lineTo(point.dx, point.dy);
        } else {
          path.roundCornerLineTo(point, prevPoint, nextPoint);
        }
      }

      path.lineTo(wire.last.dx, wire.last.dy);
      canvas.drawPath(path, wire.paint);
    }
    if (wires.isNotEmpty && wires.last.isNotEmpty && drawingWire) {
      canvas.drawLine(cursorPos, wires.last.last, linePaint);
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
