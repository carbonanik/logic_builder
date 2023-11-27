import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_grid/notifier/module_names_notifier.dart';

final moduleNamesProvider = StateNotifierProvider<ModuleNamesNotifier, Map<String, String>>(
  (ref) => ModuleNamesNotifier(ref),
);
