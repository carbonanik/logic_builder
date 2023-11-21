// import 'dart:math';
//
// typedef Comps = List<Map<String, Object?>>;
//
// int not(int a) => ~a & 1;
//
// int and(int a, int b) => a & b;
//
// int nand(int a, int b) => not(and(a, b));
//
// int or(int a, int b) => a | b;
//
// int nor(int a, int b) => not(or(a, b));
//
// int xor(int a, int b) => a ^ b;
//
// int xnor(int a, int b) => not(xor(a, b));
//
// Map<String, Map<String, Object?>> indexBy(Comps arr, String prop) {
//   return {for (var item in arr) item[prop] as String: item};
// }
//
// Comps createDFF(String name, String clk, String dIn) {
//   return [
//     {
//       "id": "$name.not_d_in",
//       "type": "not",
//       "inputs": [dIn],
//       "state": 0
//     },
//     {
//       "id": "$name.d_nand_a",
//       "type": "nand",
//       "inputs": [dIn, clk],
//       "state": 0
//     },
//     {
//       "id": "$name.q",
//       "type": "nand",
//       "inputs": ["$name.d_nand_a", "$name.q_"],
//       "state": 0
//     },
//     {
//       "id": "$name.d_nand_c",
//       "type": "nand",
//       "inputs": ["$name.not_d_in", clk],
//       "state": 0
//     },
//     {
//       "id": "$name.q_",
//       "type": "nand",
//       "inputs": ["$name.d_nand_c", "$name.q"],
//       "state": 0
//     }
//   ];
// }
//
// Comps createDFFE(String name, String clk, String dIn, String dEnable) {
//   final gatedClock = {
//     "id": "$name.clk",
//     "type": "and",
//     "inputs": [clk, dEnable],
//     "state": 0,
//   };
//
//   return [
//     gatedClock,
//     ...createDFF(name, gatedClock["id"] as String, dIn),
//   ];
// }
//
// Comps components = [
//   {
//     "id": "clock",
//     "type": "controlled",
//     "inputs": [],
//     "state": 0,
//   },
//   {
//     "id": "A",
//     "type": "controlled",
//     "inputs": [],
//     "state": 0,
//   },
//   {
//     "id": "E",
//     "type": "controlled",
//     "inputs": [],
//     "state": 0,
//   },
//   ...createDFFE("DFF", "clock", "A", "E"),
// ];
//
// final componentLookup = indexBy(components, "id");
//
// evaluate(List<Map> components, Map componentLookup) {
//   binaryOp(int Function(int, int) logicFn, component) {
//     final aOut = componentLookup[component["inputs"][0]];
//     final bOut = componentLookup[component["inputs"][1]];
//
//     component["state"] = (aOut == "x" || bOut == "x") ? "x" : logicFn(aOut["state"], bOut["state"]);
//   }
//
//   for (var component in components) {
//     switch (component["type"]) {
//       case "controlled":
//         break;
//       case "and":
//         binaryOp(and, component);
//         break;
//       case "nand":
//         binaryOp(nand, component);
//         break;
//       case "or":
//         binaryOp(or, component);
//         break;
//       case "nor":
//         binaryOp(nor, component);
//         break;
//       case "xor":
//         binaryOp(xor, component);
//         break;
//       case "xnor":
//         binaryOp(xnor, component);
//         break;
//       case "not":
//         final out = componentLookup[component["inputs"][0]];
//         component["state"] = (out == "x") ? "x" : not(out["state"]);
//         break;
//     }
//   }
// }
//
//
//
// void main() {
//   final trace = Trace(components);
//   const EVAL_PER_STEP = 5;
//   const runFor = 25;
//   for (var iteration = 0; iteration < runFor; iteration++) {
//     componentLookup["clock"]?["state"] = not(componentLookup["clock"]!["state"] as int);
//
//     if (iteration == 0){
//       componentLookup["E"]?["state"] = 1;
//     }
//
//     if (iteration == 1){
//       componentLookup["E"]?["state"] = 0;
//       componentLookup["A"]?["state"] = 1;
//     }
//
//     if (iteration == 7){
//       componentLookup["E"]?["state"] = 1;
//     }
//
//     if (iteration == 9){
//       componentLookup["E"]?["state"] = 0;
//       componentLookup["A"]?["state"] = 0;
//     }
//
//     for (var j = 0; j < EVAL_PER_STEP; j++) {
//       evaluate(components, componentLookup);
//     }
//
//     trace.sample(components, componentLookup);
//   }
//   trace.getTrace(["clock", "A", "E", "DFF.q"]).printTrace();
// }
//
// class Trace {
//   Trace(Comps components) {
//     traces = {for (var component in components) component["id"] as String: ""};
//     _maxKeyLength = traces.keys.map((e) => e.length).reduce(max);
//   }
//
//   Trace._(this.traces) {
//     _maxKeyLength = traces.keys.map((e) => e.length).reduce(max);
//   }
//
//   int _maxKeyLength = 0;
//   late Map<String, String> traces;
//   Map<String, String> filteredTraces = {};
//   final HIGH = "‾‾";
//   final LOW = "__";
//
//   void sample(Comps components, Map<String, Map<String, Object?>> componentLookup) {
//     for (var i = 0; i < components.length; i++) {
//       var old = traces[components[i]["id"] as String]!;
//
//       var newStep = (componentLookup[components[i]["id"]]!["state"] as int) == 1 ? HIGH : LOW;
//
//       if (lastStep(old) == newStep) {
//         newStep = " $newStep";
//       } else {
//         newStep = "|$newStep";
//       }
//
//       traces[components[i]["id"] as String] = old + newStep;
//     }
//   }
//
//   Trace getTrace(List<String> keys) {
//     return Trace._({for (var key in keys) key: traces[key] ?? ""});
//   }
//
//   void printTrace() {
//     traces.forEach((key, value) => print("${ps(key, _maxKeyLength + 1)}=> $value |\n\n"));
//   }
//
//   String? lastStep(String s) {
//     if (s.isNotEmpty) {
//       return s.substring(s.length - 2);
//     }
//     return null;
//   }
//
//   String ps(String s, int size) {
//     if (size > s.length) {
//       final a = size - s.length;
//       String space = "";
//       for (var i = 0; i < a; i++) {
//         space += " ";
//       }
//       return s + space;
//     } else {
//       return s.substring(0, size);
//     }
//   }
// }
