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
        "end": 2,
        "bold": false,
      },
      {
        "start": 2,
        "end": 10,
        "bold": true,
      },
    ],
  }
};

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final controller = RichTextEditingController(
    text: data["text"] as String,
    richData: RichData.fromMap(data["style"]),
  );
  String prevText = data["text"] as String;

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
                print("base offset ${controller.selection.baseOffset}");
                print("extent offset ${controller.selection.extentOffset}");
                print("delta $delta");
                controller.richData?.update(controller.selection.baseOffset, delta);
                prevText = value;
              },
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    controller.richData?.breakItem(controller.selection.baseOffset);
                  },
                  icon: const Icon(Icons.ac_unit),
                ),
                IconButton(
                  onPressed: () {},
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
  set value(TextEditingValue newValue) {
    super.value = newValue;
  }

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

  void update(int offset, int delta) {
    bool needShift = false;
    int removeIndex = -1;
    for (final (ci, segment) in segments.indexed) {
      int endCheck = delta >= 0 ? segment.end + 1 : segment.end - 1;

      if (offset >= segment.start && offset <= endCheck && !needShift) {
        segments[ci].end += delta;
        if (segments[ci].start == segments[ci].end) {
          removeIndex = ci;
        }
        needShift = true;
        continue;
      }

      if (needShift) {
        segments[ci].shift(both: delta);
      }
    }
    if (removeIndex != -1 && segments.length >= 2) {
      segments.removeAt(removeIndex);
    }
    print(toMap());
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
    print(toMap()["segments"]);
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

  RichSegment copyWith({int? start, int? end, bool? bold}) {
    return RichSegment(
      start: start ?? this.start,
      end: end ?? this.end,
      bold: bold ?? this.bold,
    );
  }

  @override
  String toString() {
    return "SegmentText{ start: $start, end: $end, bold: $bold }";
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
