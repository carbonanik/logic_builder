import 'dart:ui';

import 'package:week_task/features/logic_simulator/models/io.dart';

class MatchedIoData {
  final IO matchedIO;
  final Offset globalPos;
  final String ioId;
  final String componentId;
  final bool startFromInput;

  MatchedIoData({
    required this.matchedIO,
    required this.globalPos,
    required this.ioId,
    required this.componentId,
    required this.startFromInput,
  });

  MatchedIoData copyWith({
    IO? matchedIO,
    Offset? globalPos,
    String? ioId,
    String? componentId,
    bool? startFromInput,
  }) {
    return MatchedIoData(
      matchedIO: matchedIO ?? this.matchedIO,
      globalPos: globalPos ?? this.globalPos,
      ioId: ioId ?? this.ioId,
      componentId: componentId ?? this.componentId,
      startFromInput: startFromInput ?? this.startFromInput,
    );
  }
}
