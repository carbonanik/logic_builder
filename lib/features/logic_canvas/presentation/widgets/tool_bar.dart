import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component.dart';
import 'package:logic_builder/features/logic_canvas/presentation/widgets/component_button.dart';
import 'package:logic_builder/features/logic_canvas/presentation/widgets/tool_button.dart';

import '../../../logic_grid/provider/open_module_id_provider.dart';
import '../../data_source/provider/module_provider.dart';
import '../../provider/component_provider.dart';
import '../../provider/drawing_mode_provider.dart';
import '../../provider/is_saved_provider.dart';
import '../../provider/selected_component_provider.dart';
import '../../provider/wires_provider.dart';
import '../canvas_page.dart';
import '../mode.dart';
import 'custom_scrollbar_with_single_child_scroll_view.dart';

class ToolBar extends StatelessWidget {
  ToolBar({super.key});

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer(
          builder: (context, ref, child) {
            final mode = ref.watch(drawingModeProvider);
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.only(
                  left: 50,
                  right: 50,
                  bottom: 20,
                  top: 10,
                ),
                child: Column(
                  children: [
                    mode == Mode.component
                        ? _buildComponentButtons()
                        : const SizedBox(),
                    _buildControlButtons(),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 50,
              right: 50,
              bottom: 20,
              top: 10,
            ),
            child: _buildSaveButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildComponentButtons() {
    Color componentButtonColor(bool selected) {
      return selected ? selectionColor : Colors.grey[800]!;
    }

    Color componentButtonTextColor(bool selected) {
      return selected ? Colors.grey[800]! : Colors.grey[400]!;
    }

    selectComponent(WidgetRef ref, DiscreteComponent component) {
      ref.read(selectedComponentProvider.notifier).state = component;
    }

    return CustomScrollbarWithSingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: Consumer(builder: (context, ref, child) {
        final selectedComponent = ref.watch(selectedComponentProvider);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              reservedComponents.length,
              (index) {
                final component = reservedComponents[index];
                final isSelected = selectedComponent == component;
                return ComponentButton(
                  name: component.name,
                  onTap: () => selectComponent(ref, component),
                  color: componentButtonColor(isSelected),
                  textColor: componentButtonTextColor(isSelected),
                  key: Key(component.name),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildControlButtons() {
    Color toolButtonColor(bool selected) {
      return selected ? selectionColor : Colors.grey[800]!;
    }

    Color toolButtonIconColor(bool selected) {
      return selected ? Colors.grey[800]! : Colors.grey[400]!;
    }

    return Consumer(builder: (context, ref, child) {
      final mode = ref.watch(drawingModeProvider);

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ToolButton(
            icon: Icons.pan_tool_alt_rounded,
            color: toolButtonColor(mode == Mode.view),
            iconColor: toolButtonIconColor(mode == Mode.view),
            onTap: () {
              ref.read(drawingModeProvider.notifier).state = Mode.view;
            },
          ),
          ToolButton(
            icon: Icons.memory_rounded,
            color: toolButtonColor(mode == Mode.component),
            iconColor: toolButtonIconColor(mode == Mode.component),
            onTap: () {
              ref.read(drawingModeProvider.notifier).state = Mode.component;
            },
          ),
          ToolButton(
            icon: Icons.cable_rounded,
            color: toolButtonColor(mode == Mode.wire),
            iconColor: toolButtonIconColor(mode == Mode.wire),
            onTap: () {
              ref.read(drawingModeProvider.notifier).state = Mode.wire;
            },
          ),
          ToolButton(
            icon: Icons.delete,
            color: toolButtonColor(mode == Mode.delete),
            iconColor: toolButtonIconColor(mode == Mode.delete),
            onTap: () {
              ref.read(drawingModeProvider.notifier).state = Mode.delete;
            },
          )
        ],
      );
    });
  }

  Widget _buildSaveButton() {
    return Consumer(builder: (context, ref, child) {
      final saved = ref.watch(isSavedProvider);

      return ToolButton(
        icon: Icons.save,
        color: Colors.grey[800],
        iconColor: saved ? Colors.grey[400] : selectionColor,
        onTap: () => _save(ref),
      );
    });
  }

  _save(WidgetRef ref) async {
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
