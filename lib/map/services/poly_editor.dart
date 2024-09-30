import 'package:flutter/widgets.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mission_planer/map/services/map_configuration.dart';

class PolyEditor {
  PolyEditor({
    required this.intermediateIcon,
    required this.points,
    required this.pointIcon,
    required this.onPointsUpdated,
    this.addClosePathMarker = false,
    this.pointIconSize = MapConfiguration.markerPointIconSize,
    this.intermediateIconSize = MapConfiguration.intermediateIconSize,
  });

  final List<LatLng> points;
  final Widget pointIcon;
  final Size pointIconSize;
  final Widget? intermediateIcon;
  final Size intermediateIconSize;
  final void Function(List<LatLng>, List<DragMarker>) onPointsUpdated;
  final bool addClosePathMarker;

  int? _markerToUpdate;

  /// Aktualizacja punktu przy przeciąganiu markera
  void updateMarker(DragUpdateDetails details, LatLng point) {
    if (_markerToUpdate != null) {
      points[_markerToUpdate!] = LatLng(point.latitude, point.longitude);
    }
    _notifyUpdate(); // Wywołanie callbacka po aktualizacji
  }

  DragMarker getMarker(LatLng point, int index) {
    return DragMarker(
      point: point,
      size: pointIconSize,
      builder: (_, __, ___) => pointIcon,
      onDragStart: (_, __) => _markerToUpdate = null,
      onDragUpdate: updateMarker,
      onLongPress: (ll) => removePoint(index),
    );
  }

  /// Dodawanie nowego punktu
  List<LatLng> addPoint(LatLng point) {
    points.add(point);
    _notifyUpdate(); // Wywołanie callbacka po dodaniu nowego punktu
    return points;
  }

  /// Usuwanie punktu
  LatLng removePoint(int index) {
    final point = points.removeAt(index);
    _notifyUpdate(); // Wywołanie callbacka po usunięciu punktu
    return point;
  }

  LatLng removeLastPoint() {
    if (points.length == 1) {
      return points[0];
    }
    final point = points.removeLast();
    _notifyUpdate(); // Wywołanie callbacka po usunięciu punktu
    return point;
  }

  /// Notyfikacja dla zewnętrznego callbacka, aktualizująca punkty i markery
  void _notifyUpdate() {
    final markers = getMarkers(); // Pobieranie listy markerów
    onPointsUpdated(
      points,
      markers,
    ); // Przekazanie zaktualizowanych punktów i markerów
  }

  /// Tworzenie markerów do edycji
  List<DragMarker> getMarkers() {
    final dragMarkers = <DragMarker>[];

    // Tworzenie markerów dla istniejących punktów
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

    // Dodanie markerów pośrednich pomiędzy punktami
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
              _notifyUpdate(); // Aktualizacja po dodaniu punktu pośredniego
            },
            onDragUpdate: updateMarker,
          ),
        );
      }
    }

    // Dodanie zamknięcia ścieżki, jeśli opcja jest włączona
    if (addClosePathMarker && points.length > 2) {
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
              _notifyUpdate(); // Aktualizacja po dodaniu punktu zamykającego
            },
            onDragUpdate: updateMarker,
          ),
        );
      }
    }

    return dragMarkers;
  }
}
