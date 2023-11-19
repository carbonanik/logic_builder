import 'dart:math';

typedef Comps = List<Map<String, Object?>>;

int not(int a) => ~a & 1;

int and(int a, int b) => a & b;

int nand(int a, int b) => not(and(a, b));

int or(int a, int b) => a | b;

int nor(int a, int b) => not(or(a, b));

int xor(int a, int b) => a ^ b;

int xnor(int a, int b) => not(xor(a, b));

enum PredefinedLogicType {
  not,
  and,
  nand,
  or,
  nor,
  xor,
  xnor,
  controlled,
}

abstract class DiscreteLogic {
  final PredefinedLogicType type;
  int _state;
  final String id;

  int get state => _state;

  DiscreteLogic({
    required this.id,
    required this.type,
    int state = 0,
  }) : _state = state;

  control(int state) {
    _state = state;
  }

  run();

  @override
  String toString() {
    return 'type: ${type.toString().split(".")[1]}, state: $state';
  }
}

class NotGate extends DiscreteLogic {
  DiscreteLogic? dIn;

  NotGate({
    required String id,
    this.dIn,
    int state = 0,
  }) : super(
          id: id,
          type: PredefinedLogicType.not,
          state: state,
        );

  @override
  run() => super._state = not(dIn?.state ?? 0);
}

class AndGate extends DiscreteLogic {
  DiscreteLogic? a;
  DiscreteLogic? b;

  AndGate({
    required String id,
    this.a,
    this.b,
    int state = 0,
  }) : super(
          id: id,
          type: PredefinedLogicType.and,
          state: state,
        );

  @override
  run() => super._state = and(a?.state ?? 0, b?.state ?? 0);
}

class NandGate extends DiscreteLogic {
  DiscreteLogic? a;
  DiscreteLogic? b;

  NandGate({
    required String id,
    this.a,
    this.b,
    int state = 0,
  }) : super(
          id: id,
          type: PredefinedLogicType.nand,
          state: state,
        );

  @override
  run() => super._state = nand(a?.state ?? 0, b?.state ?? 0);
}

class OrGate extends DiscreteLogic {
  DiscreteLogic? a;
  DiscreteLogic? b;

  OrGate({
    required String id,
    this.a,
    this.b,
    int state = 0,
  }) : super(
          id: id,
          type: PredefinedLogicType.or,
          state: state,
        );

  @override
  run() => super._state = or(a?.state ?? 0, b?.state ?? 0);
}

class NorGate extends DiscreteLogic {
  DiscreteLogic? a;
  DiscreteLogic? b;

  NorGate({
    required String id,
    this.a,
    this.b,
    int state = 0,
  }) : super(
          id: id,
          type: PredefinedLogicType.nor,
          state: state,
        );

  @override
  run() => super._state = nor(a?.state ?? 0, b?.state ?? 0);
}

class Controlled extends DiscreteLogic {
  Controlled({
    required String id,
    int state = 0,
  }) : super(
          id: id,
          type: PredefinedLogicType.controlled,
          state: state,
        );

  @override
  run() => super._state = 0;
}

List<DiscreteLogic> createDFF(DiscreteLogic clk, DiscreteLogic dIn) {
  final not_d_in = NotGate(id: "DFF.not_d_in", dIn: dIn);
  final d_nand_a = NandGate(id: "DFF.d_nand_a", a: dIn, b: clk);
  final d_nand_c = NandGate(id: "DFF.d_nand_c", a: not_d_in, b: clk);
  var q_ = NandGate(id: "DFF.q_", a: d_nand_c);
  final q = NandGate(id: "DFF.q", a: d_nand_a, b: q_);
  q_.b = q;
  return [
    not_d_in,
    d_nand_a,
    q,
    d_nand_c,
    q_,
  ];
}

List<DiscreteLogic> createDFFE(DiscreteLogic clk, DiscreteLogic dIn, DiscreteLogic dEnable) {
  final gatedClock = AndGate(id: "DFF.clk", a: clk, b: dEnable);

  return [
    gatedClock,
    ...createDFF(gatedClock, dIn),
  ];
}

final clock = Controlled(id: "clock");
final A = Controlled(id: "A");
final E = Controlled(id: "E");

List<DiscreteLogic> components = [
  clock,
  A,
  E,
  ...createDFFE(clock, A, E),
];

Map<String, DiscreteLogic> indexBy(List<DiscreteLogic> arr) {
  return {for (var item in arr) item.id: item};
}

final componentLookup = indexBy(components);

evaluate(List<DiscreteLogic> components) {
  for (var component in components) {
    if (component.type != PredefinedLogicType.controlled) {
      component.run();
    }
  }
}

void main() {
  final trace = Trace(components);
  const EVAL_PER_STEP = 5;
  const runFor = 25;
  for (var iteration = 0; iteration < runFor; iteration++) {
    componentLookup["clock"]?.control(not(componentLookup["clock"]!.state));

    if (iteration == 0) {
      componentLookup["E"]?.control(1);
    }

    if (iteration == 1) {
      componentLookup["E"]?.control(0);
      componentLookup["A"]?.control(1);
    }

    if (iteration == 7) {
      componentLookup["E"]?.control(1);
    }

    if (iteration == 9) {
      componentLookup["E"]?.control(0);
      componentLookup["A"]?.control(0);
    }

    for (var j = 0; j < EVAL_PER_STEP; j++) {
      evaluate(components);
    }

    trace.sample(components, componentLookup);
  }
  trace.getTrace(["clock", "A", "E", "DFF.q"]).printTrace();
}

class Trace {
  Trace(List<DiscreteLogic> components) {
    traces = {for (var component in components) component.id: ""};
    _maxKeyLength = traces.keys.map((e) => e.length).reduce(max);
  }

  Trace._(this.traces) {
    _maxKeyLength = traces.keys.map((e) => e.length).reduce(max);
  }

  int _maxKeyLength = 0;
  late Map<String, String> traces;
  Map<String, String> filteredTraces = {};
  final HIGH = "‾‾";
  final LOW = "__";

  void sample(List<DiscreteLogic> components, Map<String, DiscreteLogic> componentLookup) {
    for (var i = 0; i < components.length; i++) {
      var old = traces[components[i].id]!;

      var newStep = componentLookup[components[i].id]!.state == 1 ? HIGH : LOW;

      if (lastStep(old) == newStep) {
        newStep = " $newStep";
      } else {
        newStep = "|$newStep";
      }

      traces[components[i].id] = old + newStep;
    }
  }

  Trace getTrace(List<String> keys) {
    return Trace._({for (var key in keys) key: traces[key] ?? ""});
  }

  void printTrace() {
    traces.forEach((key, value) => print("${ps(key, _maxKeyLength + 1)}=> $value |\n\n"));
  }

  String? lastStep(String s) {
    if (s.isNotEmpty) {
      return s.substring(s.length - 2);
    }
    return null;
  }

  String ps(String s, int size) {
    if (size > s.length) {
      final a = size - s.length;
      String space = "";
      for (var i = 0; i < a; i++) {
        space += " ";
      }
      return s + space;
    } else {
      return s.substring(0, size);
    }
  }
}
