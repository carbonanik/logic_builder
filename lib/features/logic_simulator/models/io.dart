
import 'dart:ui';

class IO {
  final String name;
  final Offset pos;
  final String id;

  IO({
    required this.id,
    required this.name,
    required this.pos,
  });

  IO copyWith({
    String? id,
    String? name,
    Offset? pos,
  }) {
    return IO(
      id: id ?? this.id,
      name: name ?? this.name,
      pos: pos ?? this.pos,
    );
  }
}
