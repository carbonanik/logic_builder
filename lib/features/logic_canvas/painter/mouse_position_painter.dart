import 'package:flutter/material.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component.dart';
import 'package:logic_builder/features/logic_canvas/models/wire.dart';

class MousePositionPainter extends CustomPainter {
  final Offset cursorPos;
  final DiscreteComponent? selectedComponent;
  final bool drawingComponent;
  final bool drawingWire;
  final List<Wire> wires;
  final Offset panOffset;

  MousePositionPainter({
    required this.cursorPos,
    required this.selectedComponent,
    required this.drawingComponent,
    required this.drawingWire,
    required this.wires,
    required this.panOffset,
  });

  final rectPaint = Paint()..style = PaintingStyle.fill..color = Colors.grey[800]!;

  final linePaint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;


  @override
  void paint(Canvas canvas, Size size) {
    drawCurrentComponent(canvas, size);
    if (wires.isNotEmpty && wires.last.isNotEmpty && drawingWire) {
      canvas.drawLine(cursorPos, wires.last.last + panOffset, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawCurrentComponent(Canvas canvas, Size size) {
    if (selectedComponent != null && drawingComponent) {
      canvas.drawRect(
        Rect.fromPoints(
          Offset.zero + cursorPos,
          Offset(selectedComponent!.size.width, selectedComponent!.size.height) + cursorPos,
        ),
        rectPaint,
      );

      drawTitle(canvas, selectedComponent!.copyWith(pos: cursorPos), Colors.grey[700]!);
    }
  }

  void drawTitle(Canvas canvas, DiscreteComponent component, Color color) {
    final textStyle = TextStyle(
      color: color,
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
    textPainter.paint(
      canvas,
      component.pos + Offset(18, component.size.height / 2 - 12),
    );
  }
}
