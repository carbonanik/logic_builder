import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/features/logic_simulator_2/event_handlers.dart';

final eventHandlerProvider = Provider((ref) => EventsHandler(ref));