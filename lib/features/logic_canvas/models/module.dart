import 'package:logic_builder/features/logic_canvas/models/discrete_component.dart';
import 'package:logic_builder/features/logic_canvas/models/wire.dart';

class Module {
  final String id ;
  final String name;
  final List<DiscreteComponent> components;
  final List<Wire> wires;

  Module({
    required this.id,
    required this.name,
    required this.components,
    required this.wires,
  });

  Module copyWith({
    String? id,
    String? name,
    List<DiscreteComponent>? components,
    List<Wire>? wires,
  }) {
    return Module(
      id: id ?? this.id,
      name: name ?? this.name,
      components: components ?? this.components,
      wires: wires ?? this.wires,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'components': components.map((e) => e.toMap()).toList(),
      'wires': wires.map((e) => e.toMap()).toList(),
    };

  }

  static Module fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'],
      name: map['name'],
      components: (map['components'] as List).map((e) => DiscreteComponent.fromMap(e)).toList(),
      wires: (map['wires'] as List).map((e) => Wire.fromMap(e)).toList(),
    );
  }
}