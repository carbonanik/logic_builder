import 'dart:ui';

import 'package:flutter/material.dart';

class CustomScrollbarWithSingleChildScrollView extends StatelessWidget {
  final ScrollController controller;
  final Widget child;
  final Axis scrollDirection;

  const CustomScrollbarWithSingleChildScrollView({
    required this.controller,
    required this.child,
    required this.scrollDirection,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: Scrollbar(
        controller: controller,
        child: SingleChildScrollView(
          controller: controller,
          scrollDirection: scrollDirection,
          child: child,
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
