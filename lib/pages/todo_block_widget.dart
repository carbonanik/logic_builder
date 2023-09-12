import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:week_task/pages/simple_todo_page.dart';

// class TodoBlockWidget extends StatefulWidget {
//   final Block block;
//   final Function updateCallback;
//   final Function? selfDeleteCallback;
//   final Function? addChildTask;
//
//   const TodoBlockWidget({
//     required this.block,
//     required this.updateCallback,
//     this.selfDeleteCallback,
//     this.addChildTask,
//     super.key,
//   });
//
//   @override
//   State<TodoBlockWidget> createState() => _TodoBlockWidgetState();
// }
//
// class _TodoBlockWidgetState extends State<TodoBlockWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ? Main title
//         widget.block.title != null
//             ? Row(
//                 children: [
//                   Stack(
//                     clipBehavior: Clip.none,
//                     alignment: AlignmentDirectional.bottomCenter,
//                     children: [
//                       // ? Add Child Task Button
//                       Positioned(
//                         bottom: -18,
//                         child: IconButton(
//                           onPressed: () {
//                             widget.addChildTask?.call();
//                           },
//                           icon: const Icon(
//                             Icons.add,
//                             size: 16,
//                           ),
//                         ),
//                       ),
//                       // ? title
//                       Padding(
//                         padding: const EdgeInsets.only(top: 10, bottom: 10),
//                         child: Text(
//                           widget.block.title!,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   // ? Delete Task button
//                   widget.selfDeleteCallback != null
//                       ? IconButton(
//                           onPressed: () {
//                             widget.selfDeleteCallback?.call();
//                           },
//                           icon: const Icon(
//                             Icons.delete,
//                             size: 18,
//                           ),
//                         )
//                       : const SizedBox(),
//                 ],
//               )
//             : const SizedBox(),
//         if (widget.block.expanded)
//           Container(
//             padding: const EdgeInsets.only(left: 0),
//             // color: getRandomColor(),
//             child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: widget.block.nestedBlocks?.length ?? 0,
//                 itemBuilder: (context, index) {
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ? nestedBlocks is not null or empty
//                       widget.block.nestedBlocks![index].nestedBlocks != null &&
//                               widget.block.nestedBlocks![index].nestedBlocks?.isNotEmpty == true
//                           ? Column(
//                               children: [
//                                 Stack(
//                                   children: [
//                                     // ? Expandable item expand button
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(vertical: 3),
//                                       child: IconButton(
//                                         onPressed: () {
//                                           widget.block.nestedBlocks![index].toggleExpanded();
//                                           widget.updateCallback();
//                                         },
//                                         icon: Icon(widget.block.nestedBlocks![index].expanded
//                                             ? Icons.arrow_drop_down
//                                             : Icons.arrow_drop_up),
//                                       ),
//                                     ),
//
//                                     // ? Expandable item indication dash
//                                     Positioned.fill(
//                                       child: Center(
//                                         child: Container(
//                                           color: Colors.black,
//                                           width: 20,
//                                           height: 2,
//                                           transform: Matrix4Transform().left(30).scaleHorizontally(1.7).matrix4,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 // ? Expanded Child Boundary
//                                 if (widget.block.nestedBlocks![index].expanded)
//                                   Stack(
//                                     alignment: AlignmentDirectional.bottomCenter,
//                                     children: [
//                                       Container(
//                                         height: 46 * (widget.block.nestedBlocks![index].height().toDouble() - 1),
//                                         width: 2,
//                                         color: Colors.black,
//                                         transform: Matrix4Transform().up(22).matrix4,
//                                       ),
//
//                                       // ? Add new task button
//                                       Container(
//                                         transform: Matrix4Transform().down(6).matrix4,
//                                         child: IconButton(
//                                           onPressed: () {
//                                             // ! Add new tasks
//                                             widget.block.nestedBlocks![index].nestedBlocks
//                                                 ?.add(Block(title: 'New Added'));
//                                             widget.updateCallback();
//                                           },
//                                           icon: const Icon(
//                                             Icons.add,
//                                             size: 20,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                               ],
//                             )
//
//                           // ? Non-Expandable item indication dash
//                           : Padding(
//                               padding: const EdgeInsets.only(
//                                 top: 22,
//                                 bottom: 22,
//                                 right: 10,
//                               ),
//                               child: Container(
//                                 transform:
//                                     // Matrix4.translationValues(-20, 0, 0)..scale(1.6, 1),
//                                     Matrix4Transform().scaleHorizontally(1.6).left(20.0).matrix4,
//                                 height: 2,
//                                 width: 30,
//                                 color: Colors.black,
//                               ),
//                             ),
//
//                       // ? One of Nested Items
//                       Expanded(
//                         child: TodoBlockWidget(
//                           block: widget.block.nestedBlocks![index],
//                           updateCallback: widget.updateCallback,
//                           selfDeleteCallback: () {
//                             widget.block.nestedBlocks!.removeAt(index);
//                             widget.updateCallback();
//                           },
//                           addChildTask: () {
//                             if (widget.block.nestedBlocks![index].nestedBlocks == null) {
//                               widget.block.nestedBlocks![index].nestedBlocks = [Block(title: 'Child')];
//                             } else {
//                               widget.block.nestedBlocks![index].nestedBlocks?.insert(0, Block(title: 'Child'));
//                             }
//
//                             widget.updateCallback();
//                           },
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//           )
//       ],
//     );
//   }
// }
//
// Color getRandomColor() {
//   return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
// }
