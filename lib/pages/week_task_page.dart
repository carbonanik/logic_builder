
import 'package:flutter/material.dart';
import 'package:week_task/models/day_tasks.dart';
import 'package:week_task/models/week_tasks.dart';
import 'package:week_task/widgets/week_tasks_widget.dart';
final tasks = [
  WeekTasks(
      title: 'Task 1',
      description: 'Description 1',
      weekOfTheYear: 31,
      year: 2023,
      dayTasks: [
        DayTasks(
          title: 'Task 1',
          // description: 'Description 1',
          dayOfWeek: 1,
        ),
        DayTasks(
          title: 'Task 2',
          // description: 'Description 2',
          dayOfWeek: 2,
        )
      ]),
  WeekTasks(
    title: 'Task 2',
    description: 'Description 2',
    weekOfTheYear: 32,
    year: 2023,
  )
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: height - kToolbarHeight,
            child: ListView.builder(
              itemCount: tasks.length + 1,
              itemBuilder: (context, index) {
                if (index < tasks.length) {
                  return WeekTasksWidget(weekTasks: tasks[index]);
                } else {
                  return Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextButton(
                          onPressed: () {
                            _showMyDialog();
                          },
                          child: const Text('Add Week'),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMyDialog() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Week'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(),
                TextField(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


