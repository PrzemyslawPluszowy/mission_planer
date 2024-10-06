import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mission_planer/core/extensions/l10n.dart';
import 'package:mission_planer/features/map/entities/polygon_ext.dart';
import 'package:mission_planer/features/map/services/map_configuration.dart';
import 'package:mission_planer/features/map/services/map_service.dart';
import 'package:mission_planer/features/map/services/poly_editor.dart';
import 'package:mission_planer/features/map/services/polygon_helper.dart';
import 'package:uuid/uuid.dart';

part 'map_view_controller_state.dart';

enum ErrorSlider {
  errorLoading,
  outsideArea;

  String l10Message(BuildContext context) {
    switch (this) {
      case ErrorSlider.errorLoading:
        return context.l10n.err_loading;
      case ErrorSlider.outsideArea:
        return context.l10n.err_outside_area;
    }
  }
}

class MapViewControllerCubit extends Cubit<MapViewControllerState> {
  MapViewControllerCubit() : super(MapViewControllerInitial()) {
    _initializeMapController();
    _loadInitialAreas();
  }

  final MapService _mapService = MapService();
  late final MapController mapController;
  late LatLng latLngCenterPoint;
  late PolyEditor _polyEditor;
  List<PolygonExt>? hidePolygonsOnEdit;
  double offsetFancyArea = 0;

  /// Inicjalizuje `MapController` i nasłuchuje na środkowy punkt mapy.
  void _initializeMapController() {
    mapController = MapController();
    mapController.mapEventStream.listen((event) {
      latLngCenterPoint = event.camera.center;
    });
  }

  /// Ładuje początkowe obszary backendu i
  ///  emituje je w stanie `MapViewControllerRefreshMap`.
  void _loadInitialAreas() {
    final areas = _mapService.loadAreas();
    emit(MapViewControllerRefreshMap(areas: areas, markers: const []));
  }

  /// Tworzy nowy wielokąt, którego pierwszy punkt to środek mapy.
  /// implementuje [_createTriangleArea] która na podstawie punktu startowego
  /// tworzy trójkąt,
  PolygonExt _createNewPolygon({
    required AreaType areaType,
    String? nestedUuid,
    Color? color,
  }) {
    final uuid = const Uuid().v4();
    return PolygonExt(
      assignedMainArea: nestedUuid,
      type: areaType,
      color: color ?? areaType.color,
      hitValue: uuid,
      uuid: uuid,
      name: MapConfiguration.defaultPolygonName,
      description: MapConfiguration.defaultPolygonDescription,
      points: _createTriangleArea(latLngCenterPoint),
    );
  }

  ///Tworzy przykładowe pole na podstawie pobranego centralnego punktu na mapie
  /// używane do tworzenia nowego wielokąta, aby użytownik nie widział
  ///  tylko jednego punktu startowego
  List<LatLng> _createTriangleArea(LatLng startPoint) {
    return [
      startPoint,
      LatLng(startPoint.latitude + 0.0003, startPoint.longitude + 0.0003),
      LatLng(startPoint.latitude + 0.0003, startPoint.longitude - 0.0003),
    ];
  }

  /// Na podstawie nowego wielokąta rozpoczyna edycję wielokąta.
  void addNewPolygon(AreaType areaType, String? nestedUuid, Color? color) {
    final newPolygon = _createNewPolygon(
      areaType: areaType,
      nestedUuid: nestedUuid,
      color: color,
    );
    final currentAreas = _getCurrentAreas();
    _initializePolygonEditor(
      polygonToEdit: newPolygon,
      currentAreas: currentAreas,
      mainUuid: nestedUuid,
    );
  }

  /// Przesuwa mapę na podany punkt.
  void _moveMap(LatLng point) {
    mapController.move(point, MapConfiguration.initialZoom);
  }

  /// Rozpoczyna edycję istniejącego wielokąta na podstawie jego UUID.
  /// > Pobiera wszzytkie obszary które są w state
  /// > przesuwa mapę na pierwszy punkt
  /// > sprawdza czy wielokąt nie jest typu [AreaType.mainArea]
  /// oraz wyszukuje wielokąt który jest przypisany do tego wielokąta
  /// służy do sprawdzania czy użytkonik nie wyszedł poza obszar główny
  void editExistingPolygon(PolygonExt polygonToEdit) {
    final currentAreas = _getCurrentAreas();
    _moveMap(
      // przesuwa mapę na pierwszy punkt wielokąta
      LatLng(
        polygonToEdit.points.first.latitude,
        polygonToEdit.points.first.longitude,
      ),
    );
    String? mainUuid;
    if (polygonToEdit.type != AreaType.mainArea) {
      mainUuid = currentAreas
          .firstWhereOrNull(
            (element) => polygonToEdit.assignedMainArea == element.uuid,
          )
          ?.uuid;
    }
    _hideEditingElement(polygonToEdit.uuid);
    _initializePolygonEditor(
      polygonToEdit: polygonToEdit,
      currentAreas: currentAreas,
      mainUuid: mainUuid,
    );
  }

  /// Ukrywa aktualnie edytowany wielokąt, aby edytor mógł operować
  /// na nowym wielokącie. Funckja usuwa wielokąt z listy obszarów
  /// oraz zapisuje go jako temp któ®y jest przywracany podczas zapisu
  void _hideEditingElement(String uuid) {
    final currentAreas = _getCurrentAreas();
    final polygonToEdit =
        currentAreas.firstWhere((element) => element.uuid == uuid);

    // Sprawdzenie, czy obszar do edycji jest głównym obszarem
    if (polygonToEdit.type == AreaType.mainArea) {
      final fancyArea = currentAreas.firstWhereOrNull(
        (element) =>
            element.assignedMainArea == polygonToEdit.uuid &&
            element.type == AreaType.fancyArea,
      );
      if (fancyArea != null) {
        currentAreas.removeWhere((element) => element.uuid == fancyArea.uuid);
      }

      // Dodanie fancyArea do listy ukrywanych poligonów
      hidePolygonsOnEdit = [polygonToEdit, if (fancyArea != null) fancyArea];
    } else {
      // Jeśli to nie główny obszar, ukrywamy tylko edytowany poligon
      hidePolygonsOnEdit = [polygonToEdit];
    }

    // Usunięcie poligonu do edycji z aktualnych obszarów
    currentAreas.removeWhere((element) => element.uuid == uuid);

    // Emitowanie zdarzenia aktualizującego mapę
    emit(
      MapViewControllerRefreshMap(
        areas: currentAreas,
        markers: const [],
        polygonToEdit: polygonToEdit,
      ),
    );
  }

  /// Inicjalizuje edytor wielokątów dla podanego wielokąta.
  /// w callbacku onPointsUpdated sprawdzane jest czy wielokąt nie wyszedł
  ///  poza obszar główny i przekazywna jest informacja do UI,
  /// emituje stan po jakielkiejkolwiek zmianie
  void _initializePolygonEditor({
    required PolygonExt polygonToEdit,
    required List<PolygonExt> currentAreas,
    String? mainUuid,
  }) {
    final mainAreaPoint = currentAreas
        .firstWhereOrNull((element) => element.uuid == mainUuid)
        ?.points;
    final snapPoints = <List<LatLng>>[];
    if (mainAreaPoint != null) {
      snapPoints
        ..add(mainAreaPoint)
        ..addAll(
          currentAreas
              .where(
                (element) =>
                    element.uuid != polygonToEdit.uuid &&
                    element.type != AreaType.fancyArea,
              )
              .map((e) => e.points),
        );
    }

    _polyEditor = PolyEditor(
      intermediateIcon: MapConfiguration.intermediateIcon,
      pointIcon: MapConfiguration.pointIcon,
      snapPoints: snapPoints,
      points: List<LatLng>.from(polygonToEdit.points),
      onPointsUpdated: (updatedPoints, markers) {
        var hasErr = false;
        if (polygonToEdit.type != AreaType.mainArea) {
          hasErr = !PolygonHelper.isPolygonInsidePolygon(
            updatedPoints,
            mainAreaPoint ?? [],
          );
        }
        if (polygonToEdit.type == AreaType.mainArea) {
          final nestedAreas = currentAreas.where(
            (element) =>
                element.assignedMainArea == polygonToEdit.uuid &&
                element.type != AreaType.fancyArea,
          );

          for (final area in nestedAreas) {
            if (!PolygonHelper.isPolygonInsidePolygon(
              area.points,
              updatedPoints,
            )) {
              hasErr = true;
              break;
            }
          }
        }
        _onPointsUpdated(
          hasErr,
          updatedPoints,
          markers,
          polygonToEdit,
          currentAreas,
        );
      },
    );
    _emitUpdatedMapState(currentAreas, _polyEditor.getMarkers(), polygonToEdit);
  }

  /// Aktualizuje stan, gdy punkty wielokąta zostaną zmienione.
  void _onPointsUpdated(
    bool hasErr,
    List<LatLng> updatedPoints,
    List<DragMarker> markers,
    PolygonExt polygonToEdit,
    List<PolygonExt> currentAreas,
  ) {
    emit(
      MapViewControllerRefreshMap(
        markers: markers,
        areas: currentAreas,
        polygonToEdit: polygonToEdit.copyWith(points: updatedPoints),
        onEdit: true,
        errorOnEdit: hasErr ? ErrorSlider.outsideArea : null,
      ),
    );
  }

  /// Emituje zaktualizowany stan mapy z nowymi markerami
  /// i edytowanym wielokątem. funkcja pomocnicza
  void _emitUpdatedMapState(
    List<PolygonExt> currentAreas,
    List<DragMarker> markers,
    PolygonExt polygonToEdit,
  ) {
    emit(
      MapViewControllerRefreshMap(
        areas: currentAreas,
        markers: markers,
        polygonToEdit: polygonToEdit,
        onEdit: true,
      ),
    );
  }

  /// Dodaje nowy punkt do wielokąta.
  /// Działa na zasadzie callbacku w [PolyEditor].
  void addPoint(LatLng point) {
    _polyEditor.addPoint(point);
  }

  /// Usuwa istniejący punkt z wielokąta.
  /// Działa na zasadzie callbacku w [PolyEditor].
  void removePoint(int index) {
    _polyEditor.removePoint(index);
  }

  /// Zwraca markery używane do edycji wielokąta.
  /// Działa na zasadzie callbacku w [PolyEditor].
  List<DragMarker> edit() {
    return _polyEditor.getMarkers();
  }

  /// Obsługuje kliknięcie użytkownika na wielokąt.
  /// Sprawdza, czy należy rozpocząć edycję klikniętego wielokąta.
  /// sprawdza czy element nie jest typu [ AreaType.fancyArea],
  /// który jest nieedytowalny i tworzy sie automatycznie
  /// jesli element jest typu [AreaType.mainArea]
  /// usuwa element [AreaType.fancyArea],
  ///  któ®y zostanie utworzony podczas zapisu
  bool onPolygonTap(LayerHitResult<Object> hitResult) {
    final isEditingMode = (state as MapViewControllerRefreshMap).onEdit;
    if (isEditingMode) {
      return true;
    }
    final tapedUuid = hitResult.hitValues.firstOrNull as String?;
    if (tapedUuid != null) {
      final polygonToEdit = _getCurrentAreas().firstWhereOrNull(
        (element) =>
            element.uuid == tapedUuid && element.type != AreaType.fancyArea,
      );
      if (polygonToEdit == null) return false;
      editExistingPolygon(polygonToEdit);
    }
    return false;
  }

  /// Anuluje edycję aktualnego wielokąta i przywraca ukryty wielokąt.
  void cancelEditing() {
    final currentAreas = _getCurrentAreas();

    if (hidePolygonsOnEdit != null) {
      currentAreas.addAll(
        hidePolygonsOnEdit!,
      );
      hidePolygonsOnEdit = null;
    }
    //sortuje miejsca klikalne według enuma [AreaType]
    currentAreas.sort(
      (a, b) => a.type.index.compareTo(b.type.index),
    );

    emit(MapViewControllerRefreshMap(areas: currentAreas, markers: const []));
  }

  /// Zapisuje nowy obszar i dodaje go do istniejącej listy obszarów.
  void saveNewArea() {
    final currentAreas = _getCurrentAreas();
    final newPolygon = _getPolygonToEdit();
    PolygonExt? fancyArea;

    if (newPolygon == null) return;
    if (newPolygon.type == AreaType.mainArea) {
      fancyArea = PolygonExt.fancyZone(
        offset: offsetFancyArea,
        points: PolygonHelper.generateFancyZone(
          newPolygon.points,
          offsetFancyArea,
        ),
        assignedMainArea: newPolygon.uuid,
      );
    }

    final updatedAreas =
        _createUpdatedAreas(currentAreas, newPolygon, fancyArea);
    emit(MapViewControllerRefreshMap(areas: updatedAreas, markers: const []));
  }

  /// Tworzy zaktualizowaną listę obszarów, dodając nowy wielokąt.
  List<PolygonExt> _createUpdatedAreas(
    List<PolygonExt> currentAreas,
    PolygonExt newPolygon,
    PolygonExt? fancyArea,
  ) {
    final updatedAreas = [
      ...currentAreas,
      if (fancyArea != null) fancyArea,
      newPolygon,
    ]..sort(
        (a, b) {
          final typeComparison = a.type.index.compareTo(b.type.index);
          if (typeComparison != 0) {
            return typeComparison;
          }
          return a.name.compareTo(b.name);
        },
      );

    return updatedAreas; // Zwracanie posortowanej listy
  }

  /// Pobiera edytowany wielokąt z aktualnego stanu.
  PolygonExt? _getPolygonToEdit() {
    return (state as MapViewControllerRefreshMap).polygonToEdit;
  }

  /// Pobiera bieżące obszary z aktualnego stanu.
  List<PolygonExt> _getCurrentAreas() {
    return (state as MapViewControllerRefreshMap).areas;
  }

  /// Usuwa ostatni punkt dodany do edytowanego wielokąta.
  /// Zwraca `false`, gdy pozostał tylko jeden punkt.
  bool undoCreatedPoints() {
    _polyEditor.removeLastPoint();
    if (_polyEditor.points.length == 1) {
      return false;
    } else {
      return true;
    }
  }

  /// Zmienia nazwę wielokąta na podstawie podanej wartości.
  /// zmiany zapisywane są podczas zapisu nowego/edytowanego obszaru.
  void changePolygonName(String value) {
    if (value.isEmpty) return;
    final polygonToEdit = _getPolygonToEdit();
    if (polygonToEdit != null) {
      final updatedPolygon = polygonToEdit.copyWith(name: value);
      emit(
        MapViewControllerRefreshMap(
          areas: _getCurrentAreas(),
          markers: _polyEditor.getMarkers(),
          polygonToEdit: updatedPolygon,
          onEdit: true,
        ),
      );
    }
  }

  /// Zmienia opis wielokąta na podstawie wprowadzonej wartości.
  /// zmiany zapisywane są podczas zapisu nowego/edytowanego obszaru.
  void changePolygonDescription(String value) {
    if (value.isEmpty) return;
    final polygonToEdit = _getPolygonToEdit();
    if (polygonToEdit != null) {
      final updatedPolygon = polygonToEdit.copyWith(description: value);
      emit(
        MapViewControllerRefreshMap(
          areas: _getCurrentAreas(),
          markers: _polyEditor.getMarkers(),
          polygonToEdit: updatedPolygon,
          onEdit: true,
        ),
      );
    }
  }

  /// Usuwa wielokąt na podstawie podanego UUID.
  /// Jeśli usuwany wielokąt główny nastepuje kaskadowe usunięcie
  /// z pod elementami
  void deletePolygon(String uuid, AreaType type) {
    final currentAreas = List<PolygonExt>.from(_getCurrentAreas());

    if (type == AreaType.mainArea) {
      currentAreas
        ..removeWhere((element) => element.assignedMainArea == uuid)
        ..removeWhere((element) => element.uuid == uuid);
    } else {
      currentAreas.removeWhere((element) => element.uuid == uuid);
    }
    emit(MapViewControllerRefreshMap(areas: currentAreas, markers: const []));
  }
}
