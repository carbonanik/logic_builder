import 'package:flutter/material.dart';
import 'package:week_task/features/logic_simulator_2/models/component_view_type.dart';
import 'package:week_task/features/logic_simulator_2/models/discrete_component.dart';
import 'package:week_task/features/logic_simulator_2/models/io.dart';

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

  final highPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.red;

  final lowPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.grey[800]!;

  final floatingPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.grey;

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
          Offset.zero + cursorPos,
          Offset(selectedComponent!.size.width, selectedComponent!.size.height) + cursorPos,
        ),
        rectPaint,
      );

      drawTitle(canvas, selectedComponent!.copyWith(pos: cursorPos), Colors.redAccent);
    }
  }

  void drawComponent(Canvas canvas, Size size) {
    for (int i = 0; i < components.length; i++) {
      final component = components[i].copyWith(pos: components[i].pos + panOffset);

      switch (components[i].viewType) {
        case ComponentViewType.basicPart:
          drawBasicViewComponent(canvas, component);
        case ComponentViewType.controlledSwitch:
          drawSwitchViewComponent(canvas, component);
        case ComponentViewType.bitOutput:
          drawBitOutputViewComponent(canvas, component);
      }
    }
  }

  void drawBasicViewComponent(Canvas canvas, DiscreteComponent component) {
    canvas.drawRect(
      Rect.fromPoints(
        component.pos,
        Offset(component.size.width, component.size.height) + component.pos,
      ),
      rectPaint,
    );

    drawIOs(canvas, component.inputs, component.pos, true);
    drawIOs(canvas, [component.output], component.pos, false);

    drawTitle(canvas, component, Colors.redAccent);
  }

  void drawSwitchViewComponent(Canvas canvas, DiscreteComponent component) {
    canvas.drawRect(
      Rect.fromPoints(
        component.pos,
        Offset(component.size.width, component.size.height) + component.pos,
      ),
      rectPaint,
    );

    const pad = Offset(4, 4);
    canvas.drawRect(
      Rect.fromPoints(
        component.pos + pad,
        Offset(component.size.width, component.size.height) + component.pos - pad,
      ),
      component.state == 0 ? lowPaint : highPaint,
    );

    // drawIOs(canvas, component.inputs, component.pos, true);
    drawIOs(canvas, [component.output], component.pos, false);

    drawTitle(canvas, component, Colors.black);
  }

  void drawBitOutputViewComponent(Canvas canvas, DiscreteComponent component) {
    canvas.drawRect(
      Rect.fromPoints(
        component.pos,
        Offset(component.size.width, component.size.height) + component.pos,
      ),
      rectPaint,
    );

    const pad = Offset(4, 4);
    canvas.drawRect(
      Rect.fromPoints(
        component.pos + pad,
        Offset(component.size.width, component.size.height) + component.pos - pad,
      ),
      component.state == 0 ? lowPaint : highPaint,
    );

    drawIOs(canvas, component.inputs, component.pos, true);
    // drawIOs(canvas, [component.output], component.pos, false);

    drawTitle(canvas, component, Colors.black);
  }

  void drawIOs(Canvas canvas, List<IO> ios, Offset partPos, bool isInput) {
    for (int i = 0; i < ios.length; i++) {
      final pos = ios[i].pos + partPos;
      final hovered = (pos - cursorPos).distance < 6;

      Paint? paint;
      final inputState = componentLookup[ios[i].id]?.state;
      if (inputState == 0) {
        paint = lowPaint;
      } else if (inputState == 1) {
        paint = highPaint;
      }

      drawIO(
        canvas,
        hovered,
        pos,
        paint ?? floatingPaint,
      );
    }
  }

  void drawIO(Canvas canvas, bool hovered, Offset pos, Paint paint) {
    if (hovered) {
      canvas.drawCircle(pos, 8, hoverIoPaint);
    }
    canvas.drawCircle(pos, 6, paint);
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
