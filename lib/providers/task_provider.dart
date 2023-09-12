import 'dart:collection';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/data_source/fake_data.dart';
import 'package:week_task/pages/simple_todo_page.dart';

class TasksNotifier extends StateNotifier<Block> {
  TasksNotifier(this.ref) : super(block);

  final Ref ref;

  void updateText(int id, String text){
    block.clearAllFocus();

    Queue<Block> searchQ = Queue();
    searchQ.add(block);

    while (searchQ.isNotEmpty) {
      Block item = searchQ.removeLast();

      if (item.id == id) {
        item.title = text;
        break;
      }

      if (item.nestedBlocks != null) {
        searchQ.addAll(item.nestedBlocks!);
      }
    }
    state = block.clone();
  }

  void addChildTask(int id) {
    block.clearAllFocus();

    Queue<Block> searchQ = Queue();
    searchQ.add(block);

    while (searchQ.isNotEmpty) {
      Block item = searchQ.removeLast();

      if (item.id == id) {
        if (item.nestedBlocks is List) {
          item.nestedBlocks?.add(Block(id: block.size() + 2, title: "", focus: true));
        } else {
          item.nestedBlocks = [Block(id: block.size() + 2, title: "", focus: true)];
        }

        break;
      }

      if (item.nestedBlocks != null) {
        searchQ.addAll(item.nestedBlocks!);
      }
    }
    state = block.clone();
  }

  void addSiblingTask(int id) {
    block.clearAllFocus();
    Queue<Block> searchQ = Queue();
    searchQ.add(block);

    while (searchQ.isNotEmpty) {
      Block item = searchQ.removeLast();

      for (final (index, child) in (item.nestedBlocks ?? []).indexed) {
        if (child.id == id) {
          // if ((item.nestedBlocks?.length ?? 0) > index) {
            item.nestedBlocks?.insert(index + 1, Block(id: block.size() + 1, title: "", focus: true));
          // } else {
          //   // item.nestedBlocks?.add(Block(id: block.size() + 1, title: "", focus: true));
          // }
          break;
        }
      }

      if (item.nestedBlocks != null) {
        searchQ.addAll(item.nestedBlocks!);
      }
    }
    state = block.clone();
  }

  void removeTask(int id) {
    block.clearAllFocus();

    Queue<Block> searchQ = Queue();
    searchQ.add(block);

    while (searchQ.isNotEmpty) {
      Block item = searchQ.removeLast();

      for (final (index, child) in (item.nestedBlocks ?? []).indexed) {
        if (child.id == id) {
          item.nestedBlocks?.removeAt(index);
          if (item.nestedBlocks?[index - 1] != null) {
            item.nestedBlocks?[index - 1].focus = true;
          }
          break;
        }
      }

      if (item.nestedBlocks != null) {
        searchQ.addAll(item.nestedBlocks!);
      }
    }
    state = block.clone();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, Block>(
  (ref) => TasksNotifier(ref),
);
