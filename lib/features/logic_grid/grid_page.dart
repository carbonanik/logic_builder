import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_grid/provider/open_module_id_provider.dart';
import 'package:logic_builder/features/logic_canvas/canvas_page.dart';
import 'package:logic_builder/features/logic_canvas/data_source/provider/mdoule_names_store_provider.dart';
import 'package:logic_builder/features/logic_canvas/data_source/provider/module_provider.dart';
import 'package:logic_builder/features/logic_canvas/models/module.dart';
import 'package:logic_builder/features/logic_grid/provider/module_names_provider.dart';
import 'package:uuid/uuid.dart';

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final width = screenWidth > 400 ? 200 : 170;
    final count = (screenWidth / width).floor();
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Create Logic',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) ? 40 : 80,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final modulesNamesMap = ref.watch(moduleNamesProvider);
                  final modulesKeys = modulesNamesMap.keys.toList();
                  return Center(
                    child: SizedBox(
                      width: (width * count).toDouble(),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count,
                        ),
                        itemCount: modulesKeys.length + 1,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildCreateProjectButton(),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildModuleCard(
                                    ref,
                                    modulesKeys[index - 1],
                                    index,
                                    context,
                                    modulesNamesMap[modulesKeys[index - 1]] ?? "Project",
                                  ),
                                );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildModuleCard(
    WidgetRef ref,
    String moduleKey,
    int index,
    BuildContext context,
    String moduleName,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(openModuleIdProvider.notifier).state = moduleKey;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CanvasPage(),
          ),
        );
      },
      child: Container(
        height: 200,
        width: 200,
        color: Colors.grey[800],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.memory_rounded, size: 60, color: Colors.redAccent),
            Text(moduleName,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
          ],
        ),
      ),
    );
  }

  Container buildCreateProjectButton() {
    return Container(
      height: 200,
      width: 200,
      color: Colors.grey[800],
      child: Center(
        child: Consumer(
          builder: (context, ref, child) {
            return GestureDetector(
              onTap: () async {
                final controller = TextEditingController();
                final AlertDialog dialog = AlertDialog(
                  title: const Text(
                    "Create New Project",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  backgroundColor: Colors.grey[800],
                  surfaceTintColor: Colors.grey,
                  shape: const RoundedRectangleBorder(),
                  content:  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Enter Project Name",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(controller.value.text);
                      },
                      child: const Text(
                        "Create",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
                final name = await showDialog<String?>(context: context, builder: (context) => dialog);
                if (name == null) {
                  return;
                }
                final openModuleId = const Uuid().v4();
                final module = Module(
                  id: openModuleId,
                  name: name,
                  components: [],
                  wires: [],
                );
                await ref.read(modulesStoreProvider).saveModule(
                      module.id,
                      module,
                    );
                ref.read(moduleNamesProvider.notifier).add(
                      openModuleId,
                      module.name,
                    );
                ref.read(openModuleIdProvider.notifier).state = openModuleId;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CanvasPage(),
                ));
              },
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey[900],
                ),
                child: Icon(
                  Icons.add,
                  size: 60,
                  color: Colors.grey[400],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
