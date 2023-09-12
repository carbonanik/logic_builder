import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/providers/task_provider.dart';

class Block {
  int id;
  String title;
  List<Block>? nestedBlocks;
  bool expanded;
  bool focus;

  Block({
    required this.id,
    required this.title,
    this.nestedBlocks,
    this.expanded = true,
    this.focus = false,
  });

  int size() {
    int s = 1;
    for (Block nestedBlock in nestedBlocks ?? []) {
      s += nestedBlock.size();
    }
    print(s);
    return s;
  }

  toggleExpanded() {
    expanded = !expanded;
  }

  Block clone() {
    return Block(
      id: id,
      title: title,
      nestedBlocks: nestedBlocks,
      expanded: expanded,
    );
  }

  void clearAllFocus() {
    focus = false;
    nestedBlocks?.forEach((element) {
      element.clearAllFocus();
    });
  }
}

class NestedTodoList extends StatelessWidget {
  const NestedTodoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Consumer(builder: (context, ref, child) {
              final blocks = ref.watch(tasksProvider);
              return TodoWidget(
                block: blocks,
              );
            }),
          ],
        ),
      ),
    );
  }
}

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

// class SimpleTodoList extends StatefulWidget {
//   const SimpleTodoList({Key? key}) : super(key: key);
//
//   @override
//   State<SimpleTodoList> createState() => _SimpleTodoListState();
// }
//
// class _SimpleTodoListState extends State<SimpleTodoList> {
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Column(
//         children: <Widget>[
//           SizedBox(
//             height: height - kToolbarHeight,
//             child: SingleChildScrollView(
//               child: TodoBlockWidget(
//                 block: block,
//                 updateCallback: () => setState(() {}),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// Future<String?> _showMyDialog(BuildContext context) async {
//   final titleController = TextEditingController();
//   return await showDialog<String?>(
//     context: context,
//     barrierDismissible: false, // user must tap button!
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Add Task'),
//         content: SingleChildScrollView(
//           child: ListBody(
//             children: <Widget>[
//               TextField(controller: titleController),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Cancel'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: const Text('Add'),
//             onPressed: () {
//               Navigator.of(context).pop(titleController.text);
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

// const colorList = [
//   Colors.red,
//   Colors.green,
//   Colors.blue,
//   Colors.yellow,
//   Colors.purple,
//   Colors.orange,
//   Colors.pink,
//   Colors.teal,
//   Colors.brown,
//   Colors.cyan,
//   Colors.grey,
//   Colors.amber,
//   Colors.deepOrange,
//   Colors.indigo,
//   Colors.lime,
// ];
