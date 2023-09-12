class Block {
  int id;
  String title;
  List<Block>? nestedBlocks;
  bool expanded;
  bool focus;

  Block({
    required this.id,
    required this.title,
    this.nestedBlocks,
    this.expanded = true,
    this.focus = false,
  });

  int size() {
    int s = 1;
    for (Block nestedBlock in nestedBlocks ?? []) {
      s += nestedBlock.size();
    }
    print(s);
    return s;
  }

  toggleExpanded() {
    expanded = !expanded;
  }

  Block clone() {
    return Block(
      id: id,
      title: title,
      nestedBlocks: nestedBlocks,
      expanded: expanded,
    );
  }

  void clearAllFocus() {
    focus = false;
    nestedBlocks?.forEach((element) {
      element.clearAllFocus();
    });
  }
}