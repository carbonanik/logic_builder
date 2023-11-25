import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:week_task/notifier/wire_notifier.dart';

final wiresProvider = ChangeNotifierProvider((ref) => WireNotifier(ref));
