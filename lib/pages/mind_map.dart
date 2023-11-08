import 'package:flutter/material.dart';
import 'package:week_task/utils/log.dart';

class MindMapWidget extends StatefulWidget {
  const MindMapWidget({super.key});

  @override
  State<MindMapWidget> createState() => _MindMapWidgetState();
}

class _MindMapWidgetState extends State<MindMapWidget> {
  FocusNode? _node;
  bool _focused = false;
  final _textController = TextEditingController();
  Node tree = Node("root");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTapUp: _handleOnTapUp,
            onDoubleTapDown: _handleOnDoubleTapDown,
            child: CustomPaint(
              painter: MindMapPainter(tree),
              child: Container(),
            ),
          ),
          Center(
            child: SizedBox(
              height: 300,
              child: Column(
                children: [_buildTextField()],
              ),
            ),
          )
        ],
      ),
    );
  }

  void toggleEditMode(String s) {
    if (_focused) {
      _node?.unfocus();
    } else {
      _textController.text = s;
    }
    setState(() {
      _focused = !_focused;
    });
  }

  void _handleOnDoubleTapDown(TapDownDetails details) {
    _selectedNode = depthFirstSearch(tree, (n) {
      final inside = n.rect?.contains(details.localPosition);
      "[$inside] rect -> ${n.rect} pos -> ${details.localPosition}".log();
      return inside ?? false;
    });
    if (_selectedNode != null) {
      toggleEditMode(_selectedNode!.value);
    }
  }

  void _handleOnTapUp(TapUpDetails details) {
    final node = depthFirstSearch(tree, (n) {
      final inside = n.rect?.contains(details.localPosition);
      "[$inside] rect -> ${n.rect} pos -> ${details.localPosition}".log();
      return inside ?? false;
    });
    if (node != null) {
      "Adding a new child to ${node.value}".log();
      setState(() {
        node.children.add(Node("child"));
      });
    } else {
      "Not tapped on a node".log();
    }
  }

  Node? _selectedNode;

  void handledTextFieldInput(String value) {
    if (_selectedNode != null) {
      _selectedNode!.value = value.trim();
      _selectedNode = null;
    }
    toggleEditMode("");
  }

  _buildTextField() {
    if (_focused) {
      return TextField(
        focusNode: _node,
        controller: _textController,
      );
    } else {
      return Container();
    }
  }
}

// =======================================================================

class Node {
  List<Node> children = [];
  String value;
  Offset? centroid;
  Rect? rect;
  Size? visualSize;

  Node(this.value);
}

Node? depthFirstSearch(Node node, bool Function(Node n) predicate) {
  if (predicate(node)) {
    return node;
  }
  for (Node child in node.children) {
    final result = depthFirstSearch(child, predicate);
    return result;
  }
  return null;
}

class MindMapPainter extends CustomPainter {
  Node tree;

  MindMapPainter(this.tree);

  final rectPaint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    drawBackground(canvas, size);

    drawCell(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    rectPaint.shader = const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Colors.deepPurple,
        Colors.purple,
      ],
    ).createShader(rect);

    canvas.drawRect(rect, rectPaint);
  }

  final padding = 10.0;

  void drawCell(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 + padding, size.height / 2);
    measureCell(tree);
    drawCellLow(canvas, center, tree);
  }

  final CellH = 30.0;

  Size? measureCell(Node node) {
    var subTreeSize = Size.zero;
    node.children.forEach((n) {
      final sz = measureCell(n);
      subTreeSize = Size(
        subTreeSize.width,
        subTreeSize.height + (sz?.height ?? 0.0),
      );
    });
    final count = node.children.length;

    // subTreeSize =
    //     Size (subTreeSize.width, subTreeSize.height + (count - 1) * padding);
    final height = subTreeSize.height > CellH ? subTreeSize.height : CellH;
    node.visualSize = Size(subTreeSize.width, height);
    return node.visualSize;
  }

  final textStyle = const TextStyle(fontSize: 20.0);
  final cellPaintFill = Paint()..color = Colors.black;
  final cellPaintBorder = Paint()..color = Colors.white;

  final CellW = 100.0;
  final displacementFactor = .75;

  void drawCellLow(Canvas canvas, Offset center, Node node) {
    final rect = Rect.fromCenter(center: center, width: CellW, height: CellH);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10.0));
    canvas.drawRRect(rrect, cellPaintFill);
    canvas.drawRRect(rrect, cellPaintBorder);
    node.centroid = center;
    node.rect = rect;
    // drawTextCentered (canvas, center, node.value, textStyle, rect.width);
    final totalHeight = node.visualSize?.height ?? 0.0;
    print("totalHeight =$totalHeight");
    final distance = rect.width * 2.0 * displacementFactor;
    var pos = Offset(distance, -totalHeight / 2.0);
    node.children.forEach((n) {
      final sz = n.visualSize;
      final vD = Offset(0, (sz?.height ?? 0) + padding);
      var c = center + pos + Offset(sz?.width ?? 0, (sz?.height ?? 0) / 2.0);
      canvas.drawLine(center + Offset(rect.width / 2.0, 0), c + Offset(-rect.width / 2.0, 0), cellPaintBorder);
      drawCellLow(canvas, c, n);
      pos += vD;
    });
  }

// void drawTextCentered( Canvas canvas, Offset position, String text, TextStyle style, double maxWidth) {
//   final tp = measureText(text, style, maxWidth);
//   final pos =position - Offset(-tp.width / 2.0, -tp.height / 2.0);
//   // paintText(canvas, tp, pos);
//
// }

// TextPainter measureText(String text, TextStyle style, double maxWidth) {
//   final span = TextSpan(text: text, style: style);
//   final tp = TextPainter(
//     text: span,
//     textAlign: TextAlign.center,
//     textDirection: TextDirection.ltr,
//   );
//   tp.layout(minWidth: 0, maxWidth: maxWidth);
//   return tp;
// }
}
