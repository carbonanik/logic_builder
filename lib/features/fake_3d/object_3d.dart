import 'package:vector_math/vector_math.dart';

class Object3D{
  final Vector3 position = Vector3.zero();

  final List<Vector3> points;

  Object3D({
    required this.points
  });
}