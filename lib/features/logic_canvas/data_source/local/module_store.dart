import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logic_builder/features/logic_canvas/models/module.dart';

const moduleBox = "modules";

class ModuleStore {
  Future<void> saveModule(String id, Module module) async {
    final box = Hive.lazyBox<String>(moduleBox);
    await box.put(id, jsonEncode(module.toMap()));
  }

  Future<Module?> getModule(String id) async {
    final box = Hive.lazyBox<String>(moduleBox);
    final map = await box.get(id);
    if (map == null) {
      return null;
    }
    return Module.fromMap(jsonDecode(map));
  }

  Future<List<String>> getAllModuleIds() async {
    final box = Hive.lazyBox<String>(moduleBox);
    return box.keys.cast<String>().toList();
  }

  Future<List<Module>> getAllModules() async {
    final ids = await getAllModuleIds();
    final modules = <Module>[];
    for (var id in ids) {
      final module = await getModule(id);
      if (module != null) {
        modules.add(module);
      }
    }
    return modules;
  }

  Future<void> deleteModule(String id) async {
    final box = Hive.lazyBox<String>(moduleBox);
    await box.delete(id);
  }

  Future<List<String>> getUsages(String id) async {
    final modules = await getAllModules();
    final usages = <String>[];
    for (var module in modules) {
      final isUsed = module.components.any((c) => c.moduleId == id);
      if (isUsed) {
        usages.add(module.name);
      }
    }
    return usages;
  }
}
