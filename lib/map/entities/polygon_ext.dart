import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PolygonExt extends Polygon {
  PolygonExt({
    required this.uuid,
    required this.name,
    required this.description,
    required super.points,
    required super.hitValue,
    super.color = const Color.fromARGB(121, 0, 0, 255),
  });
  final String uuid;
  final String name;
  final String description;

  PolygonExt copyWith({
    String? uuid,
    String? name,
    String? description,
    List<LatLng>? points,
  }) {
    return PolygonExt(
      hitValue: hitValue,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      points: points ?? this.points,
    );
  }
}
