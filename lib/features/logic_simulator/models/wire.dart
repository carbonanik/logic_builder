import 'package:flutter/material.dart';

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

  Wire copyWith({
    List<Offset>? points,
    Color? color,
    double? width,
  }) {
    return Wire(
      points: points ?? _points,
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }

  get last => _points.last;

  get first => _points.first;

  get length => _points.length;

  get isNotEmpty => _points.isNotEmpty;

  get isEmpty => _points.isEmpty;

  removeAt(int index) {
    _points.removeAt(index);
  }

  removeLast() {
    _points.removeLast();
  }

  operator [](int index) {
    return _points[index];
  }

  operator []=(int index, Offset value) {
    _points[index] = value;
  }

  @override
  String toString() {
    return _points.toString();
  }
}