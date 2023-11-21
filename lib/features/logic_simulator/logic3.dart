import 'dart:math';

int not(int a) => ~a & 1;

int and(int a, int b) => a & b;

int nand(int a, int b) => not(and(a, b));

int or(int a, int b) => a | b;

int nor(int a, int b) => not(or(a, b));

int xor(int a, int b) => a ^ b;

int xnor(int a, int b) => not(xor(a, b));

class DiscreteLogic {
  final String id;
  final PredefinedLogicType type;
  final List<String> inputs;
  final int state;

  DiscreteLogic({
    required this.id,
    required this.inputs,
    required this.type,
    this.state = 0,
  });

  DiscreteLogic copyWith({
    String? id,
    PredefinedLogicType? type,
    List<String>? inputs,
    int? state,
  }) =>
      DiscreteLogic(
        id: id ?? this.id,
        type: type ?? this.type,
        inputs: inputs ?? this.inputs,
        state: state ?? this.state,
      );
}

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

DiscreteLogic createNot(String id, String dIn) {
  return DiscreteLogic(
    id: id,
    type: PredefinedLogicType.not,
    inputs: [dIn],
  );
}

DiscreteLogic createAnd(String id, String aIn, String bIn) {
  return DiscreteLogic(
    id: id,
    type: PredefinedLogicType.and,
    inputs: [aIn, bIn],
  );
}

DiscreteLogic createNand(String id, String aIn, String bIn) {
  return DiscreteLogic(
    id: id,
    type: PredefinedLogicType.nand,
    inputs: [aIn, bIn],
  );
}

DiscreteLogic createOr(String id, String aIn, String bIn) {
  return DiscreteLogic(
    id: id,
    type: PredefinedLogicType.or,
    inputs: [aIn, bIn],
  );
}

DiscreteLogic createNor(String id, String aIn, String bIn) {
  return DiscreteLogic(
    id: id,
    type: PredefinedLogicType.nor,
    inputs: [aIn, bIn],
  );
}

DiscreteLogic createXor(String id, String aIn, String bIn) {
  return DiscreteLogic(
    id: id,
    type: PredefinedLogicType.xor,
    inputs: [aIn, bIn],
  );
}

DiscreteLogic createXnor(String id, String aIn, String bIn) {
  return DiscreteLogic(
    id: id,
    type: PredefinedLogicType.xnor,
    inputs: [aIn, bIn],
  );
}

DiscreteLogic createControlled(String id) {
  return DiscreteLogic(
    id: id,
    type: PredefinedLogicType.controlled,
    inputs: [],
  );
}

List<DiscreteLogic> createDFF(String clk, String dIn) {
  final not_d_in = createNot("DFF.not_d_in", dIn);
  final d_nand_a = createNand("DFF.d_nand_a", dIn, clk);
  final d_nand_c = createNand("DFF.d_nand_c", not_d_in.id, clk);

  const qId = "DFF.q";

  var q_ = createNand("DFF.q_", d_nand_c.id, qId);
  final q = createNand(qId, d_nand_a.id, q_.id);

  return [
    not_d_in,
    d_nand_a,
    q,
    d_nand_c,
    q_,
  ];
}

List<DiscreteLogic> createDFFE(String clk, String dIn, String dEnable) {
  final gatedClock = createAnd("DFF.clk", clk, dEnable);

  return [
    gatedClock,
    ...createDFF(gatedClock.id, dIn),
  ];
}

final clock = createControlled("clock");
final A = createControlled("A");
final E = createControlled("E");

List<DiscreteLogic> components = [
  clock,
  A,
  E,
  ...createDFFE(clock.id, A.id, E.id),
];

Map<String, DiscreteLogic> indexBy(List<DiscreteLogic> arr) {
  return {for (var item in arr) item.id: item};
}

final componentLookup = indexBy(components);

evaluate(Map<String, DiscreteLogic> componentsMap) {
  DiscreteLogic binaryOp(int Function(int, int) logicFn, DiscreteLogic component) {
    final a = componentsMap[component.inputs[0]]?.state;
    final b = componentsMap[component.inputs[1]]?.state;
    return component.copyWith(state: logicFn(a ?? 0, b ?? 0));
  }

  for (var component in componentsMap.values) {
    switch (component.type) {
      case PredefinedLogicType.controlled:
        break;
      case PredefinedLogicType.and:
        componentsMap[component.id] = binaryOp(and, component);
        break;
      case PredefinedLogicType.nand:
        componentsMap[component.id] = binaryOp(nand, component);
        break;
      case PredefinedLogicType.or:
        componentsMap[component.id] = binaryOp(or, component);
        break;
      case PredefinedLogicType.nor:
        componentsMap[component.id] = binaryOp(nor, component);
        break;
      case PredefinedLogicType.xor:
        componentsMap[component.id] = binaryOp(xor, component);
        break;
      case PredefinedLogicType.xnor:
        componentsMap[component.id] = binaryOp(xnor, component);
        break;
      case PredefinedLogicType.not:
        final a = componentsMap[component.inputs[0]]?.state;
        componentsMap[component.id] = component.copyWith(state: not(a ?? 0));
        break;
    }
  }
}

void main() {
  final trace = Trace(componentLookup);
  const EVAL_PER_STEP = 5;
  const runFor = 25;
  for (var iteration = 0; iteration < runFor; iteration++) {
    componentLookup["clock"] = componentLookup["clock"]!
        .copyWith(state: not(componentLookup["clock"]!.state));

    if (iteration == 0) {
      componentLookup["E"] = componentLookup["E"]!.copyWith(state: 1);
    }

    if (iteration == 1) {
      componentLookup["E"] = componentLookup["E"]!.copyWith(state: 0);
      componentLookup["A"] = componentLookup["A"]!.copyWith(state: 1);
    }

    if (iteration == 7) {
      componentLookup["E"] = componentLookup["E"]!.copyWith(state: 1);
    }

    if (iteration == 9) {
      componentLookup["E"] = componentLookup["E"]!.copyWith(state: 0);
      componentLookup["A"] = componentLookup["A"]!.copyWith(state: 0);
    }

    for (var j = 0; j < EVAL_PER_STEP; j++) {
      evaluate(componentLookup);
    }

    trace.sample(componentLookup);
  }
  trace.getTrace(["clock", "A", "E", "DFF.q"]).printTrace();
}

class Trace {
  Trace(Map<String, DiscreteLogic> componentsMap) {
    traces = {for (var key in componentsMap.keys) key: ""};
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

  void sample(Map<String, DiscreteLogic> componentLookup) {
    final keys = componentLookup.keys.toList();
    for (var i = 0; i < keys.length; i++) {
      var old = traces[keys[i]]!;

      var newStep = componentLookup[keys[i]]!.state == 1 ? HIGH : LOW;

      if (lastStep(old) == newStep) {
        newStep = " $newStep";
      } else {
        newStep = "|$newStep";
      }

      traces[keys[i]] = old + newStep;
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
