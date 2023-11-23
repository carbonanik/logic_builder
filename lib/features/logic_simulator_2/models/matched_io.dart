import 'dart:ui';

class MatchedIoData {
  final Offset globalPos;
  final String ioId;
  final String componentId;
  final bool startFromInput;

  MatchedIoData({
    required this.globalPos,
    required this.ioId,
    required this.componentId,
    required this.startFromInput,
  });

  MatchedIoData copyWith({
    Offset? globalPos,
    String? ioId,
    String? componentId,
    bool? startFromInput,
  }) {
    return MatchedIoData(
      globalPos: globalPos ?? this.globalPos,
      ioId: ioId ?? this.ioId,
      componentId: componentId ?? this.componentId,
      startFromInput: startFromInput ?? this.startFromInput,
    );
  }
}
