import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/features/logic_canvas/event_handlers.dart';

final eventHandlerProvider = Provider((ref) => EventsHandler(ref));
