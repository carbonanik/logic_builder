import 'dart:ui';

import 'package:logic_builder/features/logic_canvas/models/offset_map.dart';

class IO {
  final String name;
  final Offset pos;
  final String id;
  final List<String>? connectedWireIds;

  IO({
    required this.id,
    required this.name,
    required this.pos,
    this.connectedWireIds,
  });

  IO copyWith({
    String? id,
    String? name,
    Offset? pos,
    List<String>? connectedWireIds,
  }) {
    return IO(
      id: id ?? this.id,
      name: name ?? this.name,
      pos: pos ?? this.pos,
      connectedWireIds: connectedWireIds ?? this.connectedWireIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'pos': pos.toMap(),
      'connectedWireIds': connectedWireIds,
    };
  }

  static IO fromMap(Map<String, dynamic> map) {
    return IO(
      id: map['id'],
      name: map['name'],
      pos: offsetFromMap(map['pos']),
      connectedWireIds: (map['connectedWireIds'] as List?)?.map((e) => e as String).toList(),
    );
  }
}
