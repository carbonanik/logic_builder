import 'package:flutter/material.dart';

class CanvasColors {
  static const Color highColor = Colors.red;
  static final Color lowColor = Colors.grey.shade600;
  static final Color floatingColor = Colors.grey.shade800;
  static const Color hoverIoColor = Colors.grey;
  static final Color rectColor = Colors.grey.shade600;
  static const Color inputColor = Colors.blue;
  static const Color outputColor = Colors.red;
  static const Color wireColor = Colors.grey;
}

class CanvasPaints {
  static final rectPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = CanvasColors.rectColor;

  static final highPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = CanvasColors.highColor;

  static final lowPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = CanvasColors.lowColor;

  static final floatingPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = CanvasColors.floatingColor;

  static final hoverIoPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = CanvasColors.hoverIoColor;

  static final linePaint = Paint()
    ..color = CanvasColors.wireColor
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final inputPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = CanvasColors.inputColor;

  static final outputPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = CanvasColors.outputColor;
}
