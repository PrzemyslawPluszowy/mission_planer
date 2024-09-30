import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapConfiguration {
  static const double initialZoom = 15;
  static const String tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  //w razie problemow z gps ustawia start na Kraków
  static const defaultStartLatLng = LatLng(50.0617, 19.9383);

  ///UI Configuration for polygons and markers

  static const String defaultPolygonName = 'Nowe pole';
  static const String defaultPolygonDescription = 'Opis pola';
  static const Color defaultMainAreaColor = Color.fromARGB(61, 0, 0, 255);
  static const Color defaultSubAreaColor = Color.fromARGB(80, 0, 255, 0);
  static const Color defaultNoFlyZoneColor = Color.fromARGB(115, 255, 0, 0);
  static const Color defaultPolygonEdited = Color.fromARGB(117, 238, 244, 54);
  static const Color defaultPolygonColorRestictedArea =
      Color.fromARGB(61, 255, 0, 0);
  static const double defaultPolygonStrokeWidth = 2;
  static const double defaultPolygonOpacity = 0.5;
  static const intermediateIcon =
      Icon(Icons.circle, color: Color.fromARGB(255, 87, 87, 87), size: 12);
  static const intermediateIconSize = Size(12, 12);
  static const pointIcon = Icon(
    Icons.circle,
    color: Color.fromARGB(255, 255, 0, 0),
    size: 12,
  );
  static const markerPointIconSize = Size(30, 30);

  /// UI Configuration for edit bar
  static const double editBarHeight = 60;
  static final BoxDecoration editBarDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0),
        Colors.white,
        Colors.white,
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        spreadRadius: 5,
        blurRadius: 7,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
