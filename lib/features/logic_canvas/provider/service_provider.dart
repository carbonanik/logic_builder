import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/logic_simulator.dart';
import '../domain/component_service.dart';

final logicSimulatorProvider = Provider((ref) => LogicSimulator());
final componentServiceProvider = Provider((ref) => ComponentService());
