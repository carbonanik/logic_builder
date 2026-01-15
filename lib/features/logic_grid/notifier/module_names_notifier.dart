import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_canvas/data_source/provider/mdoule_names_store_provider.dart';

class ModuleNamesNotifier extends StateNotifier<Map<String, String>> {
  final Ref _ref;
  ModuleNamesNotifier(this._ref) : super({}) {
    final names = _ref.read(moduleNamesStoreProvider).getModuleNames();
    state = names;
  }

  void add(String id, String name) {
    state = {id: name, ...state};
    _ref.read(moduleNamesStoreProvider).saveModuleName(id, name);
  }

  void remove(String id) {
    final newState = Map<String, String>.from(state);
    newState.remove(id);
    state = newState;
    _ref.read(moduleNamesStoreProvider).deleteModuleName(id);
  }

  String? getName(String id) {
    return state[id];
  }
}
