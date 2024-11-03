import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../presentation/mode.dart';

final drawingModeProvider = StateProvider((ref) => Mode.view);
