import 'dart:ui';

import 'package:latlong2/latlong.dart';
import 'package:mission_planer/features/map/entities/polygon_ext.dart';

class MapService {
  List<PolygonExt> areas = [];

  List<PolygonExt> loadAreas() {
    areas.addAll(mockAreas);
    return areas;
  }

  Future<void> saveArea(PolygonExt area) async {
    final index = areas.indexWhere((element) => element.uuid == area.uuid);
    if (index != -1) {
      areas[index] = area;
    } else {
      areas.add(area);
    }
  }
}

final List<PolygonExt> mockAreas = [
  PolygonExt(
    uuid: '1',
    name: 'Area 1',
    description: 'Area 1 description',
    color: const Color.fromARGB(78, 0, 0, 255),
    points: [
      const LatLng(51.5, -0.09),
      const LatLng(51.5, -0.08),
      const LatLng(51.6, -0.08),
      const LatLng(51.6, -0.09),
    ],
    hitValue: '1',
    type: AreaType.mainArea,
  ),
];
