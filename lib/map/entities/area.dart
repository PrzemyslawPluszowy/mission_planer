import 'package:flutter_map/flutter_map.dart';
import 'package:mission_planer/map/entities/polygon_ext.dart';

class Area {
  Area({
    required this.uuid,
    required this.name,
    required this.description,
    required this.subareas,
    this.polygon,
  });
  final String uuid;
  final String name;
  final String description;
  final List<Subarea> subareas;
  final Polygon? polygon;

  Area copyWith({
    String? uuid,
    String? name,
    String? description,
    List<Subarea>? subareas,
    Polygon? polygon,
  }) {
    return Area(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      subareas: subareas ?? this.subareas,
      polygon: polygon ?? this.polygon,
    );
  }
}

class Subarea {
  Subarea({
    required this.subAreaUuid,
    required this.subareas,
    required this.restrictedAreas,
  });
  final String subAreaUuid;
  final PolygonExt subareas;
  final PolygonExt restrictedAreas;
}
