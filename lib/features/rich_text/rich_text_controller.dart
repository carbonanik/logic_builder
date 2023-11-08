import 'package:flutter/material.dart';
import 'package:week_task/features/rich_text/models/rich_data.dart';
import 'package:week_task/features/rich_text/models/rich_segment.dart';
import 'package:week_task/features/rich_text/models/rich_style.dart';

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
          style: RichStyle.defaultStyle(),
        ),
      ],
    );
    prevText = text;

    addListener(() {
      print("listener");
      if (prevText != text) {
        final delta = text.length - (prevText?.length ?? 0);
        if (delta == 1) {
          richData?.addSingleCharacter(selection.baseOffset);
        } else if (delta == -1) {
          richData?.removeSingleCharacter(selection.baseOffset);
        } else if (delta < -1) {
          richData?.removeMultiple(selection.baseOffset, delta);
        } else if (delta > 1) {
          richData?.addMultiple(selection.baseOffset, delta);
        }
        prevText = text;
      }
    });
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
          style: richData?.segments[index].style.toTextStyle(),
          text: text.substring(
            richData!.segments[index].start,
            richData!.segments[index].end,
          ),
        ),
      ),
    );
  }

  void addRich(RichStyle style){
    if (!selection.isCollapsed) {
      richData?.addRich(
        selection.baseOffset,
        selection.extentOffset,
        style,
      );
    }
  }
}
