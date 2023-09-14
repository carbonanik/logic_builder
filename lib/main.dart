import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

final data = {
  "text": "bangladesh",
  "style": {
    "length": 10,
    "segments": [
      {
        "start": 0,
        "end": 6,
        "bold": false,
      },
      {
        "start": 6,
        "end": 10,
        "bold": true,
      },
    ],
  }
};

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

const text = "Bangladesh is a country in South Asia";

class _MyAppState extends State<MyApp> {
  final controller = RichTextEditingController(
    text: text,
    // richData: RichData.fromMap(data["style"]),
  );

  String prevText = text;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Column(
          children: [
            TextField(
              controller: controller,
              onChanged: (value) {
                final delta = value.length - prevText.length;
                if (delta == 1) {
                  controller.richData?.addSingleCharacter(controller.selection.baseOffset);
                } else if (delta == -1) {
                  controller.richData?.removeSingleCharacter(controller.selection.baseOffset);
                } else if (delta < -1) {
                  controller.richData?.removeMultiple(controller.selection.baseOffset, delta);
                } else if (delta > 1) {
                  controller.richData?.addMultiple(controller.selection.baseOffset, delta);
                }
                prevText = value;
              },
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (!controller.selection.isCollapsed) {
                      controller.richData?.addRich(
                        controller.selection.baseOffset,
                        controller.selection.extentOffset,
                        true,
                      );
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.ac_unit),
                ),
                IconButton(
                  onPressed: () {
                    if (!controller.selection.isCollapsed) {
                      controller.richData?.addRich(
                        controller.selection.baseOffset,
                        controller.selection.extentOffset,
                        false,
                      );
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.local_fire_department),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class RichTextEditingController extends TextEditingController {
  RichTextEditingController({
    super.text,
    this.richData,
  }) {
    richData ??= RichData(
      length: text.length,
      segments: [
        RichSegment(
          start: 0,
          end: text.length,
          bold: false,
        ),
      ],
    );
    prevText = text;
  }

  RichData? richData;
  String? prevText;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    return TextSpan(
      style: style,
      children:
          // [TextSpan(text: text)],
          List.generate(
        richData?.segments.length ?? 0,
        (index) => TextSpan(
          style: TextStyle(
            fontSize: 20,
            fontWeight: richData!.segments[index].bold ? FontWeight.w900 : FontWeight.w100,
            color: richData!.segments[index].bold ? Colors.redAccent : Colors.greenAccent,
          ),
          text: text.substring(
            richData!.segments[index].start,
            richData!.segments[index].end,
          ),
        ),
      ),
    );
  }
}

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
    int removeIndex = -1;
    for (final (index, segment) in segments.indexed) {
      if (offset >= segment.start && offset <= segment.end - 1 && !needShift) {
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

  void addMultiple(int offset, int delta) {
    addToSingleSegment(offset - delta, delta);
  }

  void removeMultiple(int offset, int delta) {
    int needToRemove = delta;
    bool needShift = false;
    List<int> stepRemove = [];

    for (final segment in segments) {
      if (needToRemove == 0) {
        break;
      }

      if (offset >= segment.start && offset <= segment.end - 1 || needShift) {
        int canRemove = offset - segment.end;
        int nowRemove = canRemove > needToRemove ? canRemove : needToRemove;
        needToRemove -= nowRemove;
        stepRemove.add(nowRemove);
        needShift = true;
      }
    }

    for (var element in stepRemove) {
      removeFromSingleSegment(offset, element);
    }
  }

  void addRich(int baseOffset, int extentOffset, bool bold) {
    if (baseOffset == extentOffset) {
      return;
    }
    breakItem(baseOffset);
    breakItem(extentOffset);
    if (baseOffset < extentOffset) {
      combineItem(
        smallOffset: baseOffset,
        bigOffset: extentOffset,
        bold: bold,
      );
    } else {
      combineItem(
        smallOffset: extentOffset,
        bigOffset: baseOffset,
        bold: bold,
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
      final newRightSegment = segment.copyWith(
        start: breakOffset,
      );
      segments.insert(removeIndex, newLeftSegment);
      segments.insert(removeIndex + 1, newRightSegment);
    }
  }

  void combineItem({
    required int smallOffset,
    required int bigOffset,
    bool bold = false,
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
      bold: bold,
    );

    for (var i = firstIndex; i <= secondIndex; i++) {
      segments.removeAt(firstIndex);
    }

    segments.insert(firstIndex, newSegment);
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

class RichSegment {
  RichSegment({
    required this.start,
    required this.end,
    required this.bold,
  });

  int start;
  int end;
  bool bold;

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

  RichSegment copyWith({int? start, int? end, bool? bold}) {
    return RichSegment(
      start: start ?? this.start,
      end: end ?? this.end,
      bold: bold ?? this.bold,
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
      "bold": bold,
    };
  }

  static RichSegment fromMap(map) {
    return RichSegment(
      start: map["start"],
      end: map["end"],
      bold: map["bold"],
    );
  }
}
