import 'package:flutter/material.dart';
import 'package:logic_builder/features/logic_canvas/models/offset_map.dart';

class Wire {
  final String id;
  final List<Offset> _points;
  final Color color;
  final double width;
  final Paint paint;
  final String connectionId;
  final String startComponentId;
  final String? endComponentId;
  final bool startFromInput;

  Wire({
    required this.id,
    List<Offset> points = const [],
    this.color = Colors.black54,
    this.width = 3,
    required this.connectionId,
    required this.startComponentId,
    this.endComponentId,
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

  Wire copyWith({
    String? id,
    List<Offset>? points,
    Color? color,
    double? width,
    String? connectionId,
    String? startComponentId,
    String? endComponentId,
    bool? startFromInput,
  }) {
    return Wire(
      id: id ?? this.id,
      points: points ?? _points,
      color: color ?? this.color,
      width: width ?? this.width,
      connectionId: connectionId ?? this.connectionId,
      startComponentId: startComponentId ?? this.startComponentId,
      endComponentId: endComponentId ?? this.endComponentId,
      startFromInput: startFromInput ?? this.startFromInput,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'points': _points.map((point) => point.toMap()).toList(),
      'color': color.value,
      'width': width,
      'connectionId': connectionId,
      'startComponentId': startComponentId,
      'endComponentId': endComponentId,
      'startFromInput': startFromInput,
    };
  }

  static Wire fromMap(Map<String, dynamic> map) {
    return Wire(
      id: map['id'],
      points: (map['points'] as List).map((point) => offsetFromMap(point)).toList(),
      color: Color(map['color']),
      width: map['width'],
      connectionId: map['connectionId'],
      startComponentId: map['startComponentId'],
      endComponentId: map['endComponentId'],
      startFromInput: map['startFromInput'],
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
