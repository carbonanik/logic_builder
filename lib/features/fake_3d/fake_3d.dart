import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show Vector3;
import 'package:week_task/features/fake_3d/object_3d.dart';
import 'package:week_task/features/fake_3d/view_3d.dart';

class Fake3d extends StatelessWidget {
  const Fake3d({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff100808),
      appBar: AppBar(
        title: const Text("3d projection"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox.expand(
            child: View3D(
              object: cube,
            ),
          ),
        ),
      ),
    );
  }
}

final cube = Object3D(points: [
  Vector3(-1, -1, -1),
  Vector3(-1, -1, 1),
  Vector3(-1, 1, -1),
  Vector3(-1, 1, 1),

  Vector3(1, -1, -1),
  Vector3(1, -1, 1),
  Vector3(1, 1, -1),
  Vector3(1, 1, 1),
  // Vector3(1, 0.4, 0.4),
  // Vector3(1, 0.6, 0.4),
  // Vector3(1, 0.4, 0.6),
  // Vector3(1, 0.6, 0.6),

]);
