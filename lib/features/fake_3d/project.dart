import 'dart:math';

import 'package:vector_math/vector_math.dart';

Vector2 project(Vector3 point, double rotation, double aspectRatio) {
  final viewMatrix = makeViewMatrix(
    Vector3(.25, cos(rotation), sin(rotation)) * 3,
    Vector3.all(.5),
    Vector3(1, 0, 0),
  );

  const near = 1.0;
  const far = 1000.0;
  const fov = 120.0;
  const zoom = 1;
  final top = near * tan(radians(fov) / 2) / zoom;
  final bottom = -top;
  final right = top * aspectRatio;
  final left = -right;

  final projectionMatrix = makeFrustumMatrix(
    left,
    right,
    bottom,
    top,
    near,
    far,
  );

  final transformationMatrix = projectionMatrix * viewMatrix;

  final projectiveCords = Vector4(point.x, point.y, point.z, 1.0);
  projectiveCords.applyMatrix4(transformationMatrix);

  var x = projectiveCords.x / projectiveCords.w;
  var y = projectiveCords.y / projectiveCords.w;

  // final x = point.x;
  // final y = point.y;
  return Vector2(x, y);
}
