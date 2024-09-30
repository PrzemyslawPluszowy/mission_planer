import 'package:latlong2/latlong.dart';
import 'package:mission_planer/map/entities/area.dart';
import 'package:mission_planer/map/entities/polygon_ext.dart';

class MapService {
  List<Area> areas = [];
  Area? selectedArea;

  List<Area> loadAreas() {
    areas.addAll(mockAreas);
    return areas;
  }

  Future<void> saveArea(Area area) async {
    final index = areas.indexWhere((element) => element.uuid == area.uuid);
    if (index != -1) {
      areas[index] = area;
    } else {
      areas.add(area);
    }
  }
}

final List<Area> mockAreas = [
  Area(
    uuid: '1',
    name: 'Area 1',
    description: 'Description of Area 1',
    polygon: PolygonExt(
      hitValue: '1',
      uuid: '1',
      name: 'Area 1',
      description: 'Description of Area 1',
      points: [
        const LatLng(50.0617, 19.9383), // Kraków - Wawel
        const LatLng(50.0627, 19.9403), // Ulica Grodzka
        const LatLng(50.0637, 19.9433), // Rynek Główny
        const LatLng(50.0620, 19.9450), // Barbakan
        const LatLng(50.0600, 19.9420),
      ],
    ),
    subareas: [],
  ),
];
