import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_canvas/data_source/local/module_store.dart';
import 'package:logic_builder/features/logic_canvas/models/module.dart';

final modulesStoreProvider = Provider((ref) => ModuleStore());

final allModulesProvider = FutureProvider<List<Module>>((ref) async {
  final store = ref.watch(modulesStoreProvider);
  return store.getAllModules();
});
