import 'dart:ui';

extension OffsetMap on Offset {
  Map<String, double> toMap() {
    return {
      'dx': dx,
      'dy': dy,
    };
  }

  static Offset fromMap(Map<String, double> map) {
    return Offset(map['dx'] ?? 0, map['dy'] ?? 0);
  }
}

Offset offsetFromMap(Map<String, dynamic> map) {
  return Offset(map['dx'], map['dy']);
}
