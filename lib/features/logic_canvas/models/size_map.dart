import 'dart:ui';

extension SizeMap on Size {
  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
    };
  }
}

Size sizeFromMap(Map<String, dynamic> map) {
  return Size(map['width'], map['height']);
}