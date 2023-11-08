import 'package:flutter/material.dart';
import 'package:week_task/features/rich_text/models/rich_style.dart';
import 'package:week_task/features/rich_text/rich_text_controller.dart';

class RichTextEditUI extends StatefulWidget {
  const RichTextEditUI({
    required this.controller,
    required this.focusNode,
    Key? key,
  }) : super(key: key);
  final RichTextEditingController controller;
  final FocusNode focusNode;

  @override
  State<RichTextEditUI> createState() => _RichTextEditUIState();
}

class _RichTextEditUIState extends State<RichTextEditUI> {
  RichStyle? common;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        if (widget.controller.selection.baseOffset < widget.controller.selection.extentOffset) {
          common = widget.controller.richData?.getCommonFromSelected(
            smallOffset: widget.controller.selection.baseOffset,
            bigOffset: widget.controller.selection.extentOffset,
          );
        } else {
          common = widget.controller.richData?.getCommonFromSelected(
            smallOffset: widget.controller.selection.extentOffset,
            bigOffset: widget.controller.selection.baseOffset,
          );
        }
      });
      // print(common);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            var selection = widget.controller.selection.copyWith();

            final localCommon = common ?? RichStyle.defaultStyle();
            final newFontWeight = localCommon.fontWeight == FontWeight.normal ? FontWeight.bold : FontWeight.normal;
            final newStyle = localCommon.copyWith(
              fontWeight: newFontWeight,
            );

            setState(() {
              widget.controller.addRich(newStyle);
            });
            widget.focusNode.requestFocus();
            Future.delayed(const Duration(microseconds: 1), () {
              widget.controller.selection = selection;
            });
          },
          style: ButtonStyle(
            backgroundColor: common?.fontWeight == FontWeight.bold
                ? MaterialStateProperty.all(Colors.black)
                : MaterialStateProperty.all(Colors.white),
          ),
          child: Text("Bold", style: TextStyle(
            color: common?.fontWeight == FontWeight.bold
                ? Colors.white
                : Colors.black,
            fontWeight: common?.fontWeight
          ),),
        ),
        TextButton(
          onPressed: () {
            var selection = widget.controller.selection.copyWith();

            final localCommon = common ?? RichStyle.defaultStyle();
            final newFontSize = localCommon.fontSize == 18.0 ? 22.0 : 18.0;
            final newStyle = localCommon.copyWith(
              fontSize: newFontSize,
            );

            setState(() {
              widget.controller.addRich(newStyle);
            });
            widget.focusNode.requestFocus();
            Future.delayed(const Duration(microseconds: 1), () {
              widget.controller.selection = selection;
            });
          },
          style: ButtonStyle(
            backgroundColor: common?.fontSize == 22.0
                ? MaterialStateProperty.all(Colors.black)
                : MaterialStateProperty.all(Colors.white),
          ),
          child: Text("Size",
          style: TextStyle(
              color: common?.fontSize == 22.0
                  ? Colors.white
                  : Colors.black,
              fontWeight: common?.fontSize == 22.0 ? FontWeight.bold : FontWeight.normal
          ),
          ),
        ),
        TextButton(
          onPressed: () {
            var selection = widget.controller.selection.copyWith();

            final localCommon = common ?? RichStyle.defaultStyle();
            final newColor = localCommon.color == Colors.black ? Colors.redAccent : Colors.black;
            final newStyle = localCommon.copyWith(
              color: newColor,
            );

            setState(() {
              widget.controller.addRich(newStyle);
            });
            widget.focusNode.requestFocus();
            Future.delayed(const Duration(microseconds: 1), () {
              widget.controller.selection = selection;
            });
          },
          style: ButtonStyle(
            backgroundColor: common?.color == Colors.redAccent
                ? MaterialStateProperty.all(Colors.black)
                : MaterialStateProperty.all(Colors.white),
          ),
          child: Text("Color",
          style: TextStyle(
              color: common?.color == Colors.redAccent
                  ? Colors.white
                  : Colors.black,
              fontWeight: common?.color == Colors.redAccent ? FontWeight.bold : FontWeight.normal
          ),
          ),
        ),
        TextButton(
          onPressed: () {
            var selection = widget.controller.selection.copyWith();

            final localCommon = common ?? RichStyle.defaultStyle();
            final newBackgroundColor = localCommon.backgroundColor == Colors.transparent ? Colors.yellowAccent : Colors.transparent;
            final newStyle = localCommon.copyWith(
              backgroundColor: newBackgroundColor,
            );

            setState(() {
              widget.controller.addRich(newStyle);
            });
            widget.focusNode.requestFocus();
            Future.delayed(const Duration(microseconds: 1), () {
              widget.controller.selection = selection;
            });
          },
          style: ButtonStyle(
            backgroundColor: common?.backgroundColor == Colors.yellowAccent
                ? MaterialStateProperty.all(Colors.black)
                : MaterialStateProperty.all(Colors.white),
          ),
          child: Text("Color",
          style: TextStyle(
              color: common?.backgroundColor == Colors.yellowAccent
                  ? Colors.white
                  : Colors.black,
              fontWeight: common?.backgroundColor == Colors.yellowAccent ? FontWeight.bold : FontWeight.normal
          ),
          ),
        ),
      ],
    );
  }
}
