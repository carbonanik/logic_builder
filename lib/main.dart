import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_canvas/data_source/local/module_name_store.dart';
import 'package:logic_builder/features/logic_canvas/data_source/local/module_store.dart';
import 'package:logic_builder/features/logic_grid/grid_page.dart';
import 'package:logic_builder/features/providers/title_provider.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openLazyBox<String>(moduleBox);
  await Hive.openBox<String>(moduleNameBox);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: ref.watch(titleProvider),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const GridPage(),
    );
  }
}
