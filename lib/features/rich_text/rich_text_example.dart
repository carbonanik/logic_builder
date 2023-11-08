import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:week_task/features/rich_text/rich_text_controller.dart';
import 'package:week_task/features/rich_text/rich_text_edit_ui.dart';

class RichTextExample extends StatefulWidget {
  const RichTextExample({Key? key}) : super(key: key);

  @override
  State<RichTextExample> createState() => _RichTextExampleState();
}

class _RichTextExampleState extends State<RichTextExample> {
  final controller = RichTextEditingController(
    text: "bangladesh is a beautiful country",
  );

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            focusNode: focusNode,
            controller: controller,
            onChanged: (value) {},
          ),
          const Gap(5),
          RichTextEditUI(controller: controller, focusNode: focusNode),
        ],
      ),
    );
  }
}
