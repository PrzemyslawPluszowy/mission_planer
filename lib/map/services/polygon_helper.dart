import 'dart:math';

import 'package:dart_jts/dart_jts.dart';
import 'package:latlong2/latlong.dart';
import 'package:mission_planer/map/entities/polygon_ext.dart';

class PolygonHelper {
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    var intersections = 0;

    for (var i = 0; i < polygon.length; i++) {
      final vertex1 = polygon[i];
      final vertex2 = polygon[(i + 1) % polygon.length];

      if ((vertex1.latitude > point.latitude) !=
          (vertex2.latitude > point.latitude)) {
        final atLongitude = (point.latitude - vertex1.latitude) *
                (vertex2.longitude - vertex1.longitude) /
                (vertex2.latitude - vertex1.latitude) +
            vertex1.longitude;

        if (point.longitude < atLongitude) {
          intersections++;
        }
      }
    }

    return intersections.isOdd;
  }

  static bool isPolygonInsidePolygon(
    List<LatLng> innerPolygon,
    List<LatLng> outerPolygon,
  ) {
    if (outerPolygon.isEmpty) return true;
    for (final point in innerPolygon) {
      if (!isPointInPolygon(point, outerPolygon)) {
        return false;
      }
    }
    return true;
  }

  static List<MappedArea> mapToSubAreas(List<PolygonExt> areas) {
    final mappedAreas = <MappedArea>[];

    for (final area in areas) {
      if (area.type == AreaType.mainArea) {
        final subAreas = areas
            .where(
              (subArea) => subArea.assignedMainArea == area.uuid,
            )
            .toList();

        final mainPolygon = area;
        final subPolygons = subAreas;

        mappedAreas.add(
          MappedArea(
            mainPolygon: mainPolygon,
            subPolygons: subPolygons,
          ),
        );
      }
    }
    return mappedAreas;
  }

  static const double earthRadius = 6378137; // Promień Ziemi w metrach
  static double metersToDegreesLatitude(double meters) {
    return meters / 111320.0; // Stała wartość dla szerokości geograficznej
  }

  static double metersToDegreesLongitude(double meters, double latitude) {
    return meters / (111320.0 * cos(latitude * pi / 180));
  }

  static List<LatLng> generateFancyZone(
    List<LatLng> points,
    double offsetInMeters,
  ) {
    final geometryFactory = GeometryFactory.defaultPrecision();
    final coordinates = points
        .map((point) => Coordinate(point.longitude, point.latitude))
        .toList();
    if (coordinates.first != coordinates.last) {
      coordinates.add(coordinates.first);
    }
    final linearRing = geometryFactory.createLinearRing(coordinates);

    final polygon = geometryFactory.createPolygon(linearRing, []);
    final bufferDistanceLatitude = metersToDegreesLatitude(offsetInMeters);
    final bufferPolygon = polygon.buffer(bufferDistanceLatitude);
    final extendedPolygonArea = bufferPolygon
        .getCoordinates()
        .map((coord) => LatLng(coord.y, coord.x))
        .toList();

    return extendedPolygonArea;
  }
}

class MappedArea {
  MappedArea({
    required this.mainPolygon,
    required this.subPolygons,
  });
  final PolygonExt mainPolygon;
  final List<PolygonExt> subPolygons;
}
