
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/models/bloc.dart';
import 'package:week_task/pages/nested_todo_list.dart';
import 'package:week_task/providers/task_provider.dart';

class TodoWidget extends StatelessWidget {
  TodoWidget({
    required this.block,
    Key? key,
  }) : super(key: key ?? Key(block.id.toString()));
  final Block block;

  final topGap = 22.0;
  final inheritanceLineWidth = 0.5;
  final inheritanceLineColor = Colors.grey;
  late TextEditingController textEditingController = TextEditingController(text: block.title);
  late String prevText = block.title;
  final textFieldFocusNode = FocusNode();
  final keyboardFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (!textFieldFocusNode.hasFocus && block.focus) {
      // keyboardFocusNode.requestFocus();
      textFieldFocusNode.requestFocus();
      // textEditingController.selection = TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
    } else {
      // keyboardFocusNode.unfocus();
      textFieldFocusNode.unfocus();
    }

    return Container(
      // color: getRandomColor(),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Gap(topGap),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: inheritanceLineWidth,
                                      color: inheritanceLineColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Container(width: 10, height: 10, color: Colors.yellowAccent,),
                        if ((block.nestedBlocks?.length ?? 0) != 0)
                          Column(
                            children: [
                              Gap(topGap),
                              // left nested line
                              Expanded(
                                child: Container(
                                  color: inheritanceLineColor,
                                  width: inheritanceLineWidth,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // if ((block.nestedBlocks?.length ?? 0) != 0) Gap(topGap),
                ],
              ),
            ),
            // flex it according to width
            Expanded(
              flex: 10 * width ~/ 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Consumer(
                        builder: (context, ref, child) {
                          return RawKeyboardListener(
                            focusNode: keyboardFocusNode,

                            onKey: (event) {
                              if (event is RawKeyDownEvent &&
                                  event.data.physicalKey == PhysicalKeyboardKey.backspace &&
                                  textEditingController.text.isEmpty &&
                                  prevText.isEmpty) {
                                // ? remove task
                                ref.read(tasksProvider.notifier).removeTask(block.id);
                              }
                              prevText = textEditingController.text;
                            },
                            child: TextField(
                              focusNode: textFieldFocusNode,
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              onSubmitted: (value) {
                                ref.read(tasksProvider.notifier).updateText(block.id, value);
                                ref.read(tasksProvider.notifier).addSiblingTask(block.id);
                              },
                            ),
                          );
                        },
                      )),
                  Column(
                    children: List.generate(
                      block.nestedBlocks?.length ?? 0,
                          (index) => TodoWidget(
                        block: block.nestedBlocks![index],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
