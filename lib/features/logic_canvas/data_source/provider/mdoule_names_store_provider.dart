import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_canvas/data_source/local/module_name_store.dart';
import 'package:logic_builder/features/logic_grid/notifier/module_names_notifier.dart';

final moduleNamesStoreProvider = Provider((ref) => ModuleNameStore());
