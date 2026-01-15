import 'package:go_router/go_router.dart';
import 'package:logic_builder/features/logic_canvas/presentation/canvas_page.dart';
import 'package:logic_builder/features/logic_grid/grid_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const GridPage(),
      ),
      GoRoute(
        path: '/canvas/:moduleId',
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId']!;
          print(moduleId);
          return const CanvasPage();
        },
      ),
    ],
  );
});
