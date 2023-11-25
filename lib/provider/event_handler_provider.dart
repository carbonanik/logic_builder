import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/event_handlers.dart';

final eventHandlerProvider = Provider((ref) => EventsHandler(ref));
