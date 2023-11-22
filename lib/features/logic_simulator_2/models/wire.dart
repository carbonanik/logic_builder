import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Wire {
  final List<Offset> _points;
  final Color color;
  final double width;
  final Paint paint;
  final String connectionId;

  bool isCompleted = true;

  Wire({
    List<Offset> points = const [],
    this.color = Colors.brown,
    this.width = 3,
    required this.connectionId,
  })  : _points = points,
        paint = Paint()
          ..color = color
          ..strokeWidth = width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  void addPoint(Offset point) {
    _points.add(point);
  }

  Wire copyWith({
    String? connectionId,
    List<Offset>? points,
    Color? color,
    double? width,
  }) {
    return Wire(
      connectionId: connectionId ?? this.connectionId,
      points: points ?? _points,
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }

  Offset get last => _points.last;

  Offset get first => _points.first;

  int get length => _points.length;

  bool get isNotEmpty => _points.isNotEmpty;

  bool get isEmpty => _points.isEmpty;

  void removeAt(int index) {
    _points.removeAt(index);
  }

  void removeLast() {
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