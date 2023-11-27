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
}
