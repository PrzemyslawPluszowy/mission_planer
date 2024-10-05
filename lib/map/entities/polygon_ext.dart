import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mission_planer/map/services/map_configuration.dart';
import 'package:uuid/uuid.dart';

enum AreaType {
  fancyArea,
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
      case AreaType.fancyArea:
        return const Color.fromARGB(108, 244, 67, 54);
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
    this.offset = 0,
    this.assignedMainArea,
    super.isFilled = true,
    super.borderColor = Colors.transparent,
    super.borderStrokeWidth = MapConfiguration.defaultPolygonStrokeWidth,
  });

  factory PolygonExt.fancyZone({
    required List<LatLng> points,
    required String assignedMainArea,
    required double offset,
  }) {
    return PolygonExt(
      hitValue: '',
      uuid: const Uuid().v4(),
      name: 'Strefa buforowa',
      description: '',
      points: points,
      offset: offset,
      type: AreaType.fancyArea,
      color: const Color.fromARGB(111, 0, 0, 0),
      borderStrokeWidth: 1,
      assignedMainArea: assignedMainArea,
      isFilled: false,
      borderColor: const Color.fromARGB(184, 0, 0, 0),
    );
  }
  final String uuid;
  final String name;
  final String description;
  final AreaType type;
  final String? assignedMainArea;
  final double offset;

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
