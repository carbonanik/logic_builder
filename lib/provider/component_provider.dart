import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logic_builder/notifier/component_notifier.dart';

final componentsProvider = ChangeNotifierProvider((ref) => ComponentNotifier(ref));
