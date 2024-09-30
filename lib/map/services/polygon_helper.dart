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
      if (area.assignedMainArea != null) {
        final mainArea = mappedAreas.firstWhere(
          (element) => element.mainPolygon.uuid == area.assignedMainArea!,
          orElse: () => MappedArea(mainPolygon: area, subPolygons: []),
        );
        mainArea.subPolygons.add(area);
      } else {
        mappedAreas.add(MappedArea(mainPolygon: area, subPolygons: []));
      }
    }
    return mappedAreas;
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
