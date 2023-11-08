import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/rich_text/rich_text_example.dart';
import 'package:week_task/pages/experiment_list_page.dart';
import 'package:week_task/pages/logic_canvas.dart';
import 'package:week_task/pages/mind_map.dart';
import 'package:week_task/pages/nested_todo_list.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final data = {
  "text": "bangladesh is a beautiful country",
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

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const ExperimentListPage(),
      home: const LogicCanvasWidget(),
    );
  }
}

