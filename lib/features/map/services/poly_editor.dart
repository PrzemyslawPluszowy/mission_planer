import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mission_planer/features/map/services/map_configuration.dart';

class PolyEditor {
  PolyEditor({
    required this.intermediateIcon,
    required this.points,
    required this.pointIcon,
    required this.onPointsUpdated,
    this.addClosePathMarker = true,
    this.pointIconSize = MapConfiguration.markerPointIconSize,
    this.intermediateIconSize = MapConfiguration.intermediateIconSize,
    this.snapPoints = const [],
    this.distanceThreshold = 5.0,
  }) {
    genratedExpandetSnapPoint = _expandSnapPoints();
  }

  // Pola klasy
  final List<LatLng> points;
  final Widget pointIcon;
  final Size pointIconSize;
  final Widget? intermediateIcon;
  final Size intermediateIconSize;
  final void Function(List<LatLng>, List<DragMarker>) onPointsUpdated;
  final bool addClosePathMarker;
  final List<List<LatLng>> snapPoints;
  final double distanceThreshold;
  List<List<LatLng>> genratedExpandetSnapPoint = [];
  int? _markerToUpdate;

  /// Przykleja punkt do najbliższego punktu w zewnętrznych
  /// listach punktów, jeśli jest w zasięgu
  LatLng _snapPoint(LatLng point) {
    for (final snapList in genratedExpandetSnapPoint) {
      for (final snapPoint in snapList) {
        final distance = _calculateDistance(point, snapPoint);
        if (distance < distanceThreshold) {
          return snapPoint;
        }
      }
    }
    return point;
  }

  /// Aktualizacja punktu przy przeciąganiu markera,
  /// przykleja marker do najbliższego punktu w zasięgu
  void updateMarker(DragUpdateDetails details, LatLng point) {
    if (_markerToUpdate != null) {
      points[_markerToUpdate!] = LatLng(point.latitude, point.longitude);
      points[_markerToUpdate!] = _snapPoint(points[_markerToUpdate!]);
    }
    _notifyUpdate();
  }

  /// Oblicza odległość między dwoma punktami (w metrach)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const earthRadius = 6378137;
    final lat1 = point1.latitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final deltaLon = (point2.longitude - point1.longitude) * pi / 180;

    final a = sin(deltaLon / 2) * sin(deltaLon / 2) +
        cos(lat1) *
            cos(lat2) *
            sin((point2.latitude - point1.latitude) * pi / 180) *
            sin((point2.latitude - point1.latitude) * pi / 180);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Powiadamia o aktualizacji markerów i punktów
  void _notifyUpdate() {
    final markers = getMarkers();
    onPointsUpdated(points, markers);
  }

  /// Dodawanie nowego punktu do listy
  List<LatLng> addPoint(LatLng point) {
    points.add(point);
    _notifyUpdate();
    return points;
  }

  /// Usuwanie punktu z listy na podstawie indeksu
  LatLng removePoint(int index) {
    final point = points.removeAt(index);
    _notifyUpdate();
    return point;
  }

  /// Usuwanie ostatniego punktu z listy
  LatLng removeLastPoint() {
    if (points.length == 1) {
      return points[0];
    }
    final point = points.removeLast();
    _notifyUpdate();
    return point;
  }

  /// Tworzenie markerów do edycji,
  ///  które pozwalają na interakcję z punktami na mapie
  List<DragMarker> getMarkers() {
    final dragMarkers = <DragMarker>[];

    for (var c = 0; c < points.length; c++) {
      final indexClosure = c;
      dragMarkers.add(
        DragMarker(
          point: points[c],
          size: pointIconSize,
          builder: (_, __, ___) => pointIcon,
          onDragStart: (_, __) => _markerToUpdate = indexClosure,
          onDragUpdate: updateMarker,
          onLongPress: (ll) => removePoint(indexClosure),
        ),
      );
    }

    _addIntermediateMarkers(dragMarkers);
    return dragMarkers;
  }

  /// Dodawanie markerów pośrednich między punktami, oraz zamykających ścieżkę
  void _addIntermediateMarkers(List<DragMarker> dragMarkers) {
    for (var c = 0; c < points.length - 1; c++) {
      final polyPoint = points[c];
      final polyPoint2 = points[c + 1];

      if (intermediateIcon != null) {
        final intermediatePoint = LatLng(
          polyPoint.latitude + (polyPoint2.latitude - polyPoint.latitude) / 2,
          polyPoint.longitude +
              (polyPoint2.longitude - polyPoint.longitude) / 2,
        );

        dragMarkers.add(
          DragMarker(
            point: intermediatePoint,
            size: intermediateIconSize,
            builder: (_, __, ___) => intermediateIcon!,
            onDragStart: (details, point) {
              points.insert(c + 1, intermediatePoint);
              _markerToUpdate = c + 1;
              _notifyUpdate();
            },
            onDragUpdate: updateMarker,
          ),
        );
      }
    }

    if (addClosePathMarker && points.length > 2) {
      _addClosePathMarker(dragMarkers);
    }
  }

  /// Dodaje marker zamykający ścieżkę w przypadku wielokątów zamkniętych
  void _addClosePathMarker(List<DragMarker> dragMarkers) {
    if (intermediateIcon != null) {
      final finalPointIndex = points.length - 1;
      final intermediatePoint = LatLng(
        points[finalPointIndex].latitude +
            (points[0].latitude - points[finalPointIndex].latitude) / 2,
        points[finalPointIndex].longitude +
            (points[0].longitude - points[finalPointIndex].longitude) / 2,
      );

      dragMarkers.add(
        DragMarker(
          point: intermediatePoint,
          size: intermediateIconSize,
          builder: (_, __, ___) => intermediateIcon!,
          onDragStart: (details, point) {
            points.insert(finalPointIndex + 1, intermediatePoint);
            _markerToUpdate = finalPointIndex + 1;
            _notifyUpdate();
          },
          onDragUpdate: updateMarker,
        ),
      );
    }
  }

  /// Generowanie punktów pośrednich wzdłuż linii między dwoma punktami
  List<LatLng> _generatePointsAlongLine(
    LatLng start,
    LatLng end,
    int numPoints,
  ) {
    final pointsOnLine = <LatLng>[];
    const distance = Distance();

    final totalDistance = distance.as(LengthUnit.Meter, start, end);
    final segmentDistance = totalDistance / (numPoints + 1);

    for (var i = 1; i <= numPoints; i++) {
      final intermediatePoint = distance.offset(
        start,
        segmentDistance * i,
        distance.bearing(start, end),
      );
      pointsOnLine.add(intermediatePoint);
    }

    return pointsOnLine;
  }

  /// Rozszerza listę punktów na liniach prostych, dodając punkty pośrednie
  List<List<LatLng>> _expandSnapPoints() {
    final expandedSnapPoints = <List<LatLng>>[];

    for (final snapList in snapPoints) {
      final expandedSnapList = <LatLng>[];

      for (var c = 0; c < snapList.length - 1; c++) {
        final start = snapList[c];
        final end = snapList[c + 1];

        expandedSnapList.add(start);
        const numIntermediatePoints = 100;
        final additionalPoints =
            _generatePointsAlongLine(start, end, numIntermediatePoints);

        expandedSnapList.addAll(additionalPoints);
      }

      expandedSnapList.add(snapList.last);
      expandedSnapPoints.add(expandedSnapList);
    }

    return expandedSnapPoints;
  }
}
