import 'dart:ui';

import 'package:logic_builder/features/logic_canvas/models/io.dart';
import 'package:logic_builder/features/logic_canvas/models/offset_map.dart';


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

  Map<String, dynamic> toMap() {
    return {
      'matchedIO': matchedIO.toMap(),
      'globalPos': globalPos.toMap(),
      'ioId': ioId,
      'componentId': componentId,
      'startFromInput': startFromInput,

    };
  }

  static MatchedIoData fromMap(Map<String, dynamic> map) {
    return MatchedIoData(

      matchedIO: IO.fromMap(map['matchedIO']),
      globalPos: offsetFromMap(map['globalPos']),
      ioId: map['ioId'],
      componentId: map['componentId'],
      startFromInput: map['startFromInput'],

    );
  }
}
