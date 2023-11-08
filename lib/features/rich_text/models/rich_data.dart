import 'package:week_task/features/rich_text/models/rich_segment.dart';
import 'package:week_task/features/rich_text/models/rich_style.dart';

class RichData {
  RichData({
    required this.length,
    required this.segments,
  });

  int length;
  List<RichSegment> segments;

  RichData copyWith({int? length, List<RichSegment>? segments}) {
    return RichData(
      length: length ?? this.length,
      segments: segments ?? this.segments,
    );
  }

  void addSingleCharacter(int offset) {
    addToSingleSegment(offset, 1);
  }

  void removeSingleCharacter(int offset) {
    removeFromSingleSegment(offset, -1);
    removeEmpty();
  }

  void addToSingleSegment(int offset, int delta) {
    bool needShift = false;
    int removeIndex = -1;

    for (final (index, segment) in segments.indexed) {
      if (offset >= segment.start && offset <= segment.end + 1 && !needShift) {
        segment.shift(end: delta);
        if (segment.zeroWidth()) {
          removeIndex = index;
        }
        needShift = true;
        continue;
      }

      if (needShift) {
        segment.shift(both: delta);
      }
    }

    if (removeIndex != -1 && segments.length >= 2) {
      segments.removeAt(removeIndex);
    }
  }

  void removeFromSingleSegment(int offset, int delta) {
    bool needShift = false;
    for (final segment in segments) {
      if (offset >= segment.start && offset <= segment.end - 1 && !needShift) {
        segment.shift(end: delta);
        needShift = true;
        continue;
      }

      if (needShift) {
        segment.shift(both: delta);
      }
    }
  }

  void addMultiple(int offset, int delta) {
    addToSingleSegment(offset - delta, delta);
  }

  void removeMultiple(int offset, int delta) {
    int needToRemove = delta;
    bool modifyNext = false;
    List<int> stepRemove = [];

    for (final segment in segments) {
      if (needToRemove == 0) {
        break;
      }

      if (offset >= segment.start && offset <= segment.end - 1 || modifyNext) {
        int canRemove = offset - segment.end;
        int nowRemove = canRemove > needToRemove ? canRemove : needToRemove;
        stepRemove.add(nowRemove);
        needToRemove -= nowRemove;
        removeFromSingleSegment(offset, nowRemove);
        modifyNext = true;
      }
    }
    removeEmpty();
  }

  void removeEmpty() {
    segments.removeWhere((segment) => segment.zeroWidth());
    if (segments.isEmpty) {
      segments.add(RichSegment(
        start: 0,
        end: 0,
        style: RichStyle.defaultStyle(),
      ));
    }
  }

  void addRich(int baseOffset, int extentOffset, RichStyle style) {
    if (baseOffset == extentOffset) {
      return;
    }
    breakItem(baseOffset);
    breakItem(extentOffset);
    if (baseOffset < extentOffset) {
      combineItem(
        smallOffset: baseOffset,
        bigOffset: extentOffset,
        style: style,
      );
    } else {
      combineItem(
        smallOffset: extentOffset,
        bigOffset: baseOffset,
        style: style,
      );
    }
  }

  void breakItem(int breakOffset) {
    final removeIndex = segments.indexWhere(
      (segment) => segment.start < breakOffset && segment.end > breakOffset,
    );

    if (removeIndex != -1) {
      final segment = segments.removeAt(removeIndex);
      final newLeftSegment = segment.copyWith(end: breakOffset);
      final newRightSegment = segment.copyWith(start: breakOffset);
      segments.insert(removeIndex, newLeftSegment);
      segments.insert(removeIndex + 1, newRightSegment);
    }
  }

  void combineItem({
    required int smallOffset,
    required int bigOffset,
    required RichStyle style,
  }) {
    final firstIndex = segments.indexWhere(
      (segment) => segment.start == smallOffset,
    );
    final secondIndex = segments.indexWhere(
      (segment) => segment.end == bigOffset,
    );

    final newSegment = RichSegment(
      start: segments[firstIndex].start,
      end: segments[secondIndex].end,
      style: style,
    );

    for (var i = firstIndex; i <= secondIndex; i++) {
      segments.removeAt(firstIndex);
    }

    segments.insert(firstIndex, newSegment);
  }

  RichStyle? getCommonFromSelected({
    required int smallOffset,
    required int bigOffset,
  }) {
    final firstIndex = segments.indexWhere(
      (segment) => segment.start <= smallOffset && segment.end > smallOffset,
    );
    final secondIndex = segments.indexWhere(
      (segment) => segment.start < bigOffset && segment.end >= bigOffset,
    );

    RichStyle common = segments[firstIndex].style;
    for (var i = firstIndex; i <= secondIndex; i++) {
      common = segments[i].style.pickCommon(common);
    }
    return common;
  }

  @override
  String toString() {
    return "FullText{ length: $length, segments: ${segments.toString()} }";
  }

  Map toMap() {
    return {
      "length": length,
      "segments": segments.map((e) => e.toMap()).toList(),
    };
  }

  static RichData fromMap(map) {
    return RichData(
      length: map["length"],
      segments: (map["segments"] as Iterable).map((e) => RichSegment.fromMap(e)).toList(),
    );
  }
}
