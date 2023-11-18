import 'dart:ui';

import 'package:flutter/material.dart';

class Experiment extends StatelessWidget {
  const Experiment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: CustomPaint(
          painter: CirclePainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.black;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.0
      ..color = Colors.black;
    canvas.drawVertices(
      Vertices(VertexMode.triangleFan, [
        const Offset(0, 0),
        Offset(size.width, 0),
        Offset(size.width, size.height / 2),
        Offset(size.width, size.height),
        Offset(0, size.height),
        Offset(0, size.height / 2),
      ], colors: [
        const Color(0xfffdf5dd),
        const Color(0xfff0fad9),
        const Color(0xfffef9ee),
        const Color(0xfffcf5e9),
        const Color(0xfffcf2da),
        const Color(0xfff4eae4),
      ]),
      BlendMode.src,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
