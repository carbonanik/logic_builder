import 'package:flutter/foundation.dart';

extension X on Object {
  void log() {
    if (kDebugMode) {
      print(this);
    }
  }
}