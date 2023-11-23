import 'package:flutter/material.dart';

class Wire {
  final String id;
  final List<Offset> _points;
  final Color color;
  final double width;
  final Paint paint;
  final String connectionId;
  final String startComponentId;
  final bool startFromInput;

  bool isCompleted = true;

  Wire({
    required this.id,
    List<Offset> points = const [],
    this.color = Colors.brown,
    this.width = 3,
    required this.connectionId,
    required this.startComponentId,
    required this.startFromInput,
  })  : _points = points,
        paint = Paint()
          ..color = color
          ..strokeWidth = width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  void addPoint(Offset point) {
    _points.add(point);
  }

  // Wire copyWith({
  //   String? connectionId,
  //   List<Offset>? points,
  //   Color? color,
  //   double? width,
  // }) {
  //   return Wire(
  //     id: id,
  //     connectionId: connectionId ?? this.connectionId,
  //     points: points ?? _points,
  //     color: color ?? this.color,
  //     width: width ?? this.width,
  //   );
  // }

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
