import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mission_planer/map/services/map_configuration.dart';

enum AreaType {
  mainArea,
  subArea,
  noFlyZone;

  Color get color {
    switch (this) {
      case AreaType.mainArea:
        return MapConfiguration.defaultMainAreaColor;
      case AreaType.subArea:
        return MapConfiguration.defaultSubAreaColor;
      case AreaType.noFlyZone:
        return MapConfiguration.defaultNoFlyZoneColor;
    }
  }
}

class PolygonExt extends Polygon {
  PolygonExt({
    required this.uuid,
    required this.name,
    required this.description,
    required super.points,
    required super.hitValue,
    required this.type,
    required super.color,
    this.assignedMainArea,
  });
  final String uuid;
  final String name;
  final String description;
  final AreaType type;
  final String? assignedMainArea;

  PolygonExt copyWith({
    String? uuid,
    String? name,
    String? description,
    List<LatLng>? points,
    AreaType? type,
    String? assignedMainArea,
    Color? color,
  }) {
    return PolygonExt(
      color: color ?? this.color,
      hitValue: hitValue,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      points: points ?? this.points,
      type: type ?? this.type,
      assignedMainArea: assignedMainArea ?? this.assignedMainArea,
    );
  }
}
