import 'dart:math';

class Pair<T, U> {
  final T a;
  final U b;

  Pair(
    this.a,
    this.b,
  );

  X? valueOf<X>() {
    if (a is X) {
      return a as X?;
    } else if (b is X) {
      return b as X?;
    }
    return null;
  }
}

// main() {
//   final p = Pair(1, "string");
//
//   final int? s = p.valueOf();
//   print(s);
// }
