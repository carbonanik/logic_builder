import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/notifier/wire_notifier.dart';

final wiresProvider = ChangeNotifierProvider((ref) => WireNotifier(ref));

