
import 'dart:ui';

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
}
