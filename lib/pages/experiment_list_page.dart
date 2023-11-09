import 'package:flutter/material.dart';
import 'package:week_task/features/rich_text/rich_text_example.dart';
import 'package:week_task/features/logic_simulator/logic_canvas.dart';
import 'package:week_task/pages/nested_todo_list.dart';

class ExperimentListPage extends StatelessWidget {
  const ExperimentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text("Experiment:\n "
                "Complex ui with nested data", style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
            const SizedBox(height: 60),
            FilledButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const NestedTodoList();
                }));
              },
              child: const Text("Nested Todo List"),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const RichTextExample();
                }));
              },
              child: const Text("Rich Text Example"),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const LogicCanvasWidget();
                }));
              },
              child: const Text("Logic Canvas"),
            )
          ],
        ),
      ),
    );
  }
}
