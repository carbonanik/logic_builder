import 'package:hive_flutter/hive_flutter.dart';

const moduleNameBox = "name_modules";

class ModuleNameStore {
  Future<void> saveModuleName(String id, String name) async {
    final box = Hive.box<String>(moduleNameBox);
    await box.put(id, name);
  }

  Map<String, String> getModuleNames() {
    final box = Hive.box<String>(moduleNameBox);
    final names = box.toMap().map((key, value) => MapEntry<String, String>(key, value));
    return names;
  }
}
