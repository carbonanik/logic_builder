import 'package:week_task/models/block.dart';
import 'package:week_task/pages/nested_todo_list.dart';

final block = Block(
  id: 1,
  title: 'Project',
  nestedBlocks: [
    Block(
      id: 2,
      title: 'Task 1',
      nestedBlocks: [
        Block(id: 5, title: 'Task 1.1'),
        Block(
          id: 6,
          title: 'Task 1.2',
          nestedBlocks: [
            Block(id: 7, title: 'Task 1.2.1'),
            Block(id: 8, title: 'Task 1.2.2'),
            Block(id: 9, title: 'Task 1.2.3'),
          ],
        ),
      ],
    ),
    Block(id: 3, title: 'Task 2'),
    Block(
      id: 4,
      title: 'Task 3',
      nestedBlocks: [
        Block(
          id: 10,
          title: 'Task 3.1',
          nestedBlocks: [
            Block(
                id: 11,
                title: 'Task 3.1.1'),
          ],
        ),
      ],
    ),
    // Block(
    //   title: 'Task 1',
    //   nestedBlocks: [
    //     Block(title: 'Task 1.1'),
    //     Block(
    //       title: 'Task 1.2',
    //       nestedBlocks: [
    //         Block(title: 'Task 1.2.1'),
    //         Block(title: 'Task 1.2.2'),
    //         Block(title: 'Task 1.2.3'),
    //       ],
    //     ),
    //   ],
    // ),
    // Block(title: 'Task 2'),
    // Block(
    //   title: 'Task 3',
    //   nestedBlocks: [
    // Block(
    //   title: 'Task 1',
    //   nestedBlocks: [
    //     Block(title: 'Task 1.1'),
    //     Block(
    //       title: 'Task 1.2',
    //       nestedBlocks: [
    //         Block(title: 'Task 1.2.1'),
    //         Block(title: 'Task 1.2.2'),
    //         Block(title: 'Task 1.2.3'),
    //       ],
    //     ),
    //   ],
    // ),
    // Block(
    //   title: 'Task 3.1',
    //   nestedBlocks: [
    //     Block(title: 'Task 3.1.1'),
    //   ],
    // ),
    // ],
    // ),
  ],
);
