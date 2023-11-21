import 'package:flutter/material.dart';
import 'package:week_task/features/logic_simulator_2/models/discrete_component.dart';

class LogicPainter extends CustomPainter {
  final List<DiscreteComponent> components;
  final Map<String, DiscreteComponent> componentLookup;
  final Offset cursorPos;
  final DiscreteComponent? selectedComponent;
  final bool drawingComponent;
  final Offset panOffset;

  LogicPainter({
    required this.components,
    required this.componentLookup,
    required this.cursorPos,
    required this.selectedComponent,
    required this.drawingComponent,
    required this.panOffset,
  });

  final rectPaint = Paint()..style = PaintingStyle.fill;

  final inputPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.blue;

  final outputPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.red;

  final highPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.red;

  final lowPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.blue;

  final floatingPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.black;

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
    drawCurrentComponent(canvas, size);
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

      drawTitle(canvas, selectedComponent!.copyWith(pos: cursorPos));
    }
  }

  void drawComponent(Canvas canvas, Size size) {
    for (int i = 0; i < components.length; i++) {
      final component = components[i].copyWith(pos: components[i].pos + panOffset);

      canvas.drawRect(
        Rect.fromPoints(
          component.pos,
          Offset(component.size.width, component.size.height) + component.pos,
        ),
        rectPaint,
      );

      drawIOs(canvas, component.inputs, component.pos, inputPaint);
      drawIOs(canvas, [component.output], component.pos, outputPaint);

      drawTitle(canvas, component);
    }
  }

  void drawIOs(Canvas canvas, List<IO> ios, Offset partPos, Paint paint) {
    for (int i = 0; i < ios.length; i++) {
      final pos = ios[i].pos + partPos;
      final hovered = (pos - cursorPos).distance < 6;
      drawIO(canvas, hovered, pos, paint);
    }
  }

  void drawIO(Canvas canvas, bool hovered, Offset pos, Paint paint) {
    if (hovered) {
      canvas.drawCircle(pos, 8, hoverIoPaint);
    }
    canvas.drawCircle(pos, 6, paint);
  }

  void drawTitle(Canvas canvas, DiscreteComponent component) {
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
    textPainter.paint(
      canvas,
      component.pos + Offset(18, component.size.height / 2 - 12),
    );
  }
}
