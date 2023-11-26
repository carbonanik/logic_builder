import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logic_builder/features/logic_canvas/models/module.dart';

const singleID = "single";
const moduleBox = "modules";

class ModuleStore {
  Future<void> saveModule(Module module) async {
    final box = Hive.lazyBox<String>(moduleBox);
    await box.put(singleID, jsonEncode(module.toMap()));
  }

  Future<Module?> getModule() async {
    final box = Hive.lazyBox<String>(moduleBox);
    final map = await box.get(singleID);
    // final map = box.values.cast<Map<String, dynamic>>().firstOrNull;
    if (map == null) {
      return null;
    }
    return Module.fromMap( jsonDecode( map));
  }
}
