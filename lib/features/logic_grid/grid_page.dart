import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_grid/provider/open_module_id_provider.dart';
import 'package:logic_builder/features/logic_canvas/data_source/provider/module_provider.dart';
import 'package:logic_builder/features/logic_canvas/models/module.dart';
import 'package:logic_builder/features/logic_grid/provider/module_names_provider.dart';
import 'package:logic_builder/features/providers/title_provider.dart';
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
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 10,
                    ),
                    child: Text(
                      'Logic Builder',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: (defaultTargetPlatform ==
                                    TargetPlatform.iOS ||
                                defaultTargetPlatform == TargetPlatform.android)
                            ? 40
                            : 80,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        "Friendly and lightweight tool to Design digital logic circuits",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize:
                              (defaultTargetPlatform == TargetPlatform.iOS ||
                                      defaultTargetPlatform ==
                                          TargetPlatform.android)
                                  ? 16
                                  : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
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
                                    modulesNamesMap[modulesKeys[index - 1]] ??
                                        "Project",
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
        ref.read(titleProvider.notifier).state = moduleName;
        context.push('/canvas/$moduleKey');
      },
      child: Stack(
        children: [
          Container(
            height: 200,
            width: 200,
            color: Colors.grey[800],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.memory_rounded,
                    size: 60, color: Colors.redAccent),
                Text(moduleName,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              onPressed: () =>
                  _handleDelete(ref, moduleKey, moduleName, context),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(
    WidgetRef ref,
    String moduleKey,
    String moduleName,
    BuildContext context,
  ) async {
    final usages = await ref.read(modulesStoreProvider).getUsages(moduleKey);

    if (context.mounted) {
      if (usages.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[800],
            title: const Text("Cannot Delete",
                style: TextStyle(color: Colors.white)),
            content: Text(
              "This module is being used in the ${usages.join(", ")} module.",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("OK", style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      } else {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[800],
            title: const Text("Delete Module",
                style: TextStyle(color: Colors.white)),
            content: Text(
              "Are you sure you want to delete '$moduleName'?",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete",
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );

        if (confirm == true) {
          ref.read(moduleNamesProvider.notifier).remove(moduleKey);
          await ref.read(modulesStoreProvider).deleteModule(moduleKey);
        }
      }
    }
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
                final AlertDialog dialog = buildDialog(controller, context);
                final name = await showDialog<String?>(
                    context: context, builder: (context) => dialog);
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
                ref.read(titleProvider.notifier).state = name;
                controller.dispose();
                if (context.mounted) {
                  context.push('/canvas/$openModuleId');
                }
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

  AlertDialog buildDialog(
      TextEditingController controller, BuildContext context) {
    return AlertDialog(
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
      content: TextField(
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
  }
}
