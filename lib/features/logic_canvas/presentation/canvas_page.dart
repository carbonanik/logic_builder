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
