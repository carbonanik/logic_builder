import 'dart:math';
import 'package:flutter/material.dart';
import 'package:week_task/features/fake_3d/object_3d.dart';
import 'package:week_task/features/fake_3d/project.dart';

class View3D extends StatefulWidget {
  final Object3D object;

  const View3D({
    required this.object,
    super.key,
  });

  @override
  State<View3D> createState() => _View3DState();
}

class _View3DState extends State<View3D> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _View3DPainter(object: widget.object, animation: controller),
    );
  }
}

class _View3DPainter extends CustomPainter {
  final Object3D object;
  final Animation animation;

  _View3DPainter({
    required this.object,
    required this.animation,
  }): super(repaint: animation);

  final _paint = Paint()..color = Colors.red;

  static const _pallet = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    var aspectRatio = size.width / size.height;
    for (final (i, point) in object.points.indexed) {
      const pointSize = 5.0;
      var screenPoint = project(point, animation.value * pi * 2, aspectRatio);

      final color = _pallet[i % _pallet.length];
      _paint.color = color;

      // Remap coordinates form [-1, 1] to the [0, viewport].
      final x = (1 + screenPoint.x) * size.width / 2;
      final y = (1 - screenPoint.y) * size.height / 2;

      canvas.drawCircle(Offset(x, y), pointSize, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
