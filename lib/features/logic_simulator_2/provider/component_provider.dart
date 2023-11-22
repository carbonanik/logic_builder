import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/logic_simulator_2/notifier/component_notifier.dart';

final componentsProvider = ChangeNotifierProvider((ref) => ComponentNotifier(ref));
