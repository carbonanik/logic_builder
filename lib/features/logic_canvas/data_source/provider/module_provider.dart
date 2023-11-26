import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_canvas/data_source/local/module_store.dart';

final modulesStoreProvider = Provider((ref) => ModuleStore());