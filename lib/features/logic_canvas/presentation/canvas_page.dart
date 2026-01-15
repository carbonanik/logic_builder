import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_canvas/presentation/widgets/drawing_board.dart';
import 'package:logic_builder/features/logic_canvas/presentation/widgets/tool_bar.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component_type.dart';
import 'package:logic_builder/features/logic_canvas/provider/is_saved_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/component_provider.dart';
import 'package:logic_builder/features/logic_canvas/provider/wires_provider.dart';
import 'package:logic_builder/features/logic_grid/provider/open_module_id_provider.dart';
import 'package:logic_builder/features/logic_canvas/data_source/provider/module_provider.dart';
import 'package:logic_builder/features/providers/title_provider.dart';

final reservedComponents = [
  createComponent(DiscreteComponentType.and),
  createComponent(DiscreteComponentType.or),
  createComponent(DiscreteComponentType.not),
  createComponent(DiscreteComponentType.nand),
  createComponent(DiscreteComponentType.nor),
  createComponent(DiscreteComponentType.controlled),
  createComponent(DiscreteComponentType.output),
  createComponent(DiscreteComponentType.clock),
];

const selectionColor = Colors.redAccent;

class CanvasPage extends ConsumerWidget {
  const CanvasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(isSavedProvider);

    return PopScope(
      canPop: isSaved,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showUnsavedDialog(context, ref);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            DrawingBoard(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  right: 16,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final title = ref.watch(titleProvider);
                        return Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ToolBar(),
          ],
        ),
      ),
    );
  }

  Future<bool> _showUnsavedDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Unsaved Changes",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "You have unsaved changes. Do you want to save them before leaving?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child:
                const Text("Discard", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child:
                const Text("Save", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (result == 'save') {
      await _save(ref);
      return true;
    } else if (result == 'discard') {
      ref.read(isSavedProvider.notifier).state = true;
      return true;
    }
    return false;
  }

  Future<void> _save(WidgetRef ref) async {
    final wires = ref.read(wiresProvider).wires;
    final components = ref.read(componentsProvider).components;
    final openModuleId = ref.read(openModuleIdProvider);

    if (openModuleId == null) return;
    final module = await ref.read(modulesStoreProvider).getModule(openModuleId);
    if (module == null) return;

    await ref.read(modulesStoreProvider).saveModule(
          openModuleId,
          module.copyWith(
            wires: wires,
            components: components,
          ),
        );
    ref.read(isSavedProvider.notifier).state = true;
  }
}
