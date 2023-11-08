import 'package:flutter/material.dart';
import 'package:week_task/features/rich_text/rich_text_example.dart';
import 'package:week_task/pages/logic_canvas.dart';
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return NestedTodoList();
                }));
              },
              child: Text("Nested Todo List"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return RichTextExample();
                }));
              },
              child: Text("Rich Text Example"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return LogicCanvasWidget();
                }));
              },
              child: Text("Logic Canvas"),
            )
          ],
        ),
      ),
    );
  }
}
