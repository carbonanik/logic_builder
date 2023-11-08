import 'package:week_task/features/rich_text/models/rich_style.dart';

class RichSegment {
  RichSegment({
    required this.start,
    required this.end,
    required this.style,
  });

  int start;
  int end;
  RichStyle style;

  void shift({
    int? both,
    int? start,
    int? end,
  }) {
    if (both != null) {
      this.start += both;
      this.end += both;
    } else if (start != null) {
      this.start += start;
    } else if (end != null) {
      this.end += end;
    }
  }

  bool zeroWidth() {
    return start == end;
  }

  RichSegment copyWith({int? start, int? end, RichStyle? style}) {
    return RichSegment(
      start: start ?? this.start,
      end: end ?? this.end,
      style: style ?? this.style,
    );
  }

  @override
  String toString() {
    return "[$start...$end)";
  }

  Map toMap() {
    return {
      "start": start,
      "end": end,
      "style": style.toMap(),
    };
  }

  static RichSegment fromMap(map) {
    return RichSegment(
      start: map["start"],
      end: map["end"],
      style: RichStyle.fromMap(map["style"]),
    );
  }
}


