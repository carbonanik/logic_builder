import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/event_handlers.dart';

final eventHandlerProvider = Provider((ref) => EventsHandler(ref));
