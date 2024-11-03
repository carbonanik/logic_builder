import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logic_builder/features/logic_canvas/presentation/widgets/drawing_board.dart';
import 'package:logic_builder/features/logic_canvas/presentation/widgets/tool_bar.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component.dart';
import 'package:logic_builder/features/logic_canvas/models/discrete_component_type.dart';

final reservedComponents = [
  createComponent(DiscreteComponentType.and),
  createComponent(DiscreteComponentType.or),
  createComponent(DiscreteComponentType.not),
  createComponent(DiscreteComponentType.nand),
  createComponent(DiscreteComponentType.nor),
  createComponent(DiscreteComponentType.controlled),
  createComponent(DiscreteComponentType.output),
];

const selectionColor = Colors.redAccent;

class CanvasPage extends StatelessWidget {
  const CanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          DrawingBoard(),
          ToolBar(),
        ],
      ),
    );
  }
}


