import 'dart:math';

import 'package:dart_jts/dart_jts.dart';
import 'package:latlong2/latlong.dart';

class PolygonHelper {
  static const double earthRadius = 6378137; // Promień Ziemi w metrach

  // Sprawdza, czy wewnętrzny wielokąt mieści się w zewnętrznym
  static bool isPolygonInsidePolygon(
    List<LatLng> innerPolygon,
    List<LatLng> outerPolygon, {
    double snapTolerance = 0.00000001,
  }) {
    if (outerPolygon.isEmpty) return false; // Zmiana na false

    // Sprawdź, czy każdy punkt wewnętrznego wielokąta
    // znajduje się w zewnętrznym wielokącie lub na jego krawędzi
    for (final point in innerPolygon) {
      if (!isPointInPolygon(
            point,
            outerPolygon,
            snapTolerance: snapTolerance,
          ) &&
          !isPointOnPolygonEdge(
            point,
            outerPolygon,
            snapTolerance: snapTolerance,
          )) {
        return false; // Jeśli którykolwiek punkt jest poza, zwróć false
      }
    }

    // Jeśli nie ma pokrycia, zwróć true
    return true;
  }

  // Sprawdza, czy punkt znajduje się wewnątrz wielokąta
  static bool isPointInPolygon(
    LatLng point,
    List<LatLng> polygon, {
    double snapTolerance = 0.00000001,
  }) {
    var intersections = 0;
    for (var i = 0; i < polygon.length; i++) {
      final vertex1 = polygon[i];
      final vertex2 = polygon[(i + 1) % polygon.length];

      // Sprawdza, czy linia pionowa przechodzi przez odcinek wielokąta
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

  // Dodaje funkcję, która sprawdza, czy punkt leży na krawędzi wielokąta
  static bool isPointOnPolygonEdge(
    LatLng point,
    List<LatLng> polygon, {
    double snapTolerance = 1e-10,
  }) {
    for (var i = 0; i < polygon.length; i++) {
      final vertex1 = polygon[i];
      final vertex2 = polygon[(i + 1) % polygon.length];
      if (isPointOnLineSegment(point, vertex1, vertex2, snapTolerance)) {
        return true; // Punkt leży na krawędzi
      }
    }
    return false; // Punkt nie leży na żadnej krawędzi
  }

  // Funkcja sprawdzająca, czy punkt leży na odcinku
  static bool isPointOnLineSegment(
    LatLng point,
    LatLng lineStart,
    LatLng lineEnd,
    double snapTolerance,
  ) {
    final crossProduct = (point.latitude - lineStart.latitude) *
            (lineEnd.longitude - lineStart.longitude) -
        (point.longitude - lineStart.longitude) *
            (lineEnd.latitude - lineStart.latitude);

    if (crossProduct.abs() > snapTolerance) {
      return false; // Punkt nie leży na linii
    }

    final dotProduct = (point.latitude - lineStart.latitude) *
            (lineEnd.latitude - lineStart.latitude) +
        (point.longitude - lineStart.longitude) *
            (lineEnd.longitude - lineStart.longitude);
    if (dotProduct < -snapTolerance) {
      return false; // Punkt leży przed punktem początkowym
    }

    final squaredLength = (lineEnd.latitude - lineStart.latitude) *
            (lineEnd.latitude - lineStart.latitude) +
        (lineEnd.longitude - lineStart.longitude) *
            (lineEnd.longitude - lineStart.longitude);
    if (dotProduct > squaredLength + snapTolerance) {
      return false; // Punkt leży za punktem końcowym
    }

    return true; // Punkt leży na odcinku
  }

  // Konwertuje odległość w metrach na stopnie szerokości geograficznej
  static double metersToDegreesLatitude(double meters) {
    return meters / 111320.0;
  }

  // Konwertuje odległość w metrach na stopnie długości geograficznej
  static double metersToDegreesLongitude(double meters, double latitude) {
    return meters / (111320.0 * cos(latitude * pi / 180));
  }

  // Oblicza liczbę segmentów kwadrantu na podstawie liczby wierzchołków
  static int calculateQuadrantSegments(int numVertices) {
    return -10 * numVertices;
  }

  // Generuje rozszerzoną strefę (np. bufory wokół wielokąta)
  static List<LatLng> generateFancyZone(
    List<LatLng> points,
    double offsetInMeters,
  ) {
    final geometryFactory = GeometryFactory.defaultPrecision();
    final coordinates = points
        .map((point) => Coordinate(point.longitude, point.latitude))
        .toList();

    if (coordinates.first != coordinates.last) {
      coordinates.add(coordinates.first); // Zamknięcie wielokąta
    }

    final linearRing = geometryFactory.createLinearRing(coordinates);
    final polygon = geometryFactory.createPolygon(linearRing, []);

    final bufferDistanceLatitude = metersToDegreesLatitude(offsetInMeters);
    final quadrantSegments = calculateQuadrantSegments(points.length);

    final bufferPolygon = polygon.buffer3(
      bufferDistanceLatitude,
      quadrantSegments,
      BufferOp.CAP_BUTT,
    );

    return bufferPolygon
        .getCoordinates()
        .map((coord) => LatLng(coord.y, coord.x))
        .toList();
  }
}
