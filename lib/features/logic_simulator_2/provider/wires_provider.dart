import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/logic_simulator_2/notifier/wire_notifier.dart';

final wiresProvider = ChangeNotifierProvider((ref) => WireNotifier());
