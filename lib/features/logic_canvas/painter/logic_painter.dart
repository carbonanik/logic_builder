import 'package:flutter/material.dart';
import 'package:logic_builder/features/logic_canvas/models/component_view_type.dart';
import 'package:logic_builder/features/logic_canvas/painter/canvas_style.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component.dart';
import 'package:logic_builder/features/logic_canvas/models/io.dart';

class LogicPainter extends CustomPainter {
  final List<DiscreteComponent> components;
  final Map<String, DiscreteComponent> componentLookup;
  final Offset cursorPos;
  final Offset panOffset;

  LogicPainter({
    required this.components,
    required this.componentLookup,
    required this.cursorPos,
    required this.panOffset,
  });

  final rectPaint = CanvasPaints.rectPaint;

  final highPaint = CanvasPaints.highPaint;

  final lowPaint = CanvasPaints.lowPaint;

  final floatingPaint = CanvasPaints.floatingPaint;

  final hoverIoPaint = CanvasPaints.hoverIoPaint;

  final linePaint = CanvasPaints.linePaint;

  @override
  void paint(Canvas canvas, Size size) {
    drawComponent(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawComponent(Canvas canvas, Size size) {
    for (int i = 0; i < components.length; i++) {
      final component =
          components[i].copyWith(pos: components[i].pos + panOffset);

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
    drawIOs(canvas, component.outputs, component.pos, false);

    drawTitle(canvas, component, Colors.grey[800]!);
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
        Offset(component.size.width, component.size.height) +
            component.pos -
            pad,
      ),
      component.state == 0 ? lowPaint : highPaint,
    );

    // drawIOs(canvas, component.inputs, component.pos, true);
    drawIOs(canvas, component.outputs, component.pos, false);

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
        Offset(component.size.width, component.size.height) +
            component.pos -
            pad,
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
      final hovered = (pos - cursorPos).distance < 10; // todo this was 6

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
        isInput ? ios[i].name : null,
      );
    }
  }

  void drawIO(
      Canvas canvas, bool hovered, Offset pos, Paint paint, String? label) {
    if (hovered) {
      canvas.drawCircle(pos, 8, hoverIoPaint);
    }
    canvas.drawCircle(pos, 6, paint);

    if (label != null) {
      final textStyle = TextStyle(
        color: Colors.grey[600],
        fontSize: 10,
      );
      final textSpan = TextSpan(
        text: label,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        pos + const Offset(8, -5),
      );
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
