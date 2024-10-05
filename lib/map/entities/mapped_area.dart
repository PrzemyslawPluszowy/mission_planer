import 'package:mission_planer/map/entities/polygon_ext.dart';

class MappedArea {
  MappedArea({
    required this.mainPolygon,
    required this.subPolygons,
  });

  final PolygonExt mainPolygon;
  final List<PolygonExt> subPolygons;

  // Mapuje listę obszarów na listę
  // złożoną z głównego obszaru i jego podobszarów
  // wyswietla sie w right menu
  static List<MappedArea> mapToSubAreas(List<PolygonExt> areas) {
    return areas
        .where((area) => area.type == AreaType.mainArea)
        .map((mainArea) {
      final subAreas = areas
          .where((subArea) => subArea.assignedMainArea == mainArea.uuid)
          .toList();

      return MappedArea(
        mainPolygon: mainArea,
        subPolygons: subAreas,
      );
    }).toList();
  }
}
