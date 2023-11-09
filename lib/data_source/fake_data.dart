import 'package:week_task/models/block.dart';
import 'package:uuid/uuid.dart' as uuid;

final block = Block(
  id: const uuid.Uuid().v4(),
  title: 'Project',
  nestedBlocks: [
    Block(
      id: const uuid.Uuid().v4(),
      title: 'Task 1',
      nestedBlocks: [
        Block(id: const uuid.Uuid().v4(), title: 'Task 1.1'),
        Block(
          id: const uuid.Uuid().v4(),
          title: 'Task 1.2',
          nestedBlocks: [
            Block(id: const uuid.Uuid().v4(), title: 'Task 1.2.1'),
            Block(id: const uuid.Uuid().v4(), title: 'Task 1.2.2'),
            Block(id: const uuid.Uuid().v4(), title: 'Task 1.2.3'),
          ],
        ),
      ],
    ),
    Block(id: const uuid.Uuid().v4(), title: 'Task 2'),
    Block(
      id: const uuid.Uuid().v4(),
      title: 'Task 3',
      nestedBlocks: [
        Block(
          id: const uuid.Uuid().v4(),
          title: 'Task 3.1',
          nestedBlocks: [
            Block(
                id: const uuid.Uuid().v4(),
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
