import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/models/wire.dart';
import 'package:week_task/provider/wires_provider.dart';

final isDrawingWire = StateProvider((ref) => false);

final isControlPressed = StateProvider((ref) => false);

final currentDrawingWireIdProvider = StateProvider<String?>((ref) => null);

final currentWireProvider = Provider<Wire?>((ref) {
  final cid = ref.watch(currentDrawingWireIdProvider);
  if (cid == null) {
    return null;
  }
  return ref.watch(wiresProvider).wiresLookup[cid];
});

