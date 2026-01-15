import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_canvas/data_source/local/module_name_store.dart';
import 'package:logic_builder/features/logic_canvas/data_source/local/module_store.dart';
import 'package:logic_builder/features/providers/title_provider.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:logic_builder/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Hive.initFlutter();
  await Hive.openLazyBox<String>(moduleBox);
  await Hive.openBox<String>(moduleNameBox);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: ref.watch(titleProvider),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
