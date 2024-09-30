import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mission_planer/map/entities/polygon_ext.dart';
import 'package:mission_planer/map/services/map_configuration.dart';
import 'package:mission_planer/map/services/map_service.dart';
import 'package:mission_planer/map/services/poly_editor.dart';
import 'package:mission_planer/map/services/polygon_helper.dart';
import 'package:uuid/uuid.dart';

part 'map_view_controller_state.dart';

class MapViewControllerCubit extends Cubit<MapViewControllerState> {
  MapViewControllerCubit() : super(MapViewControllerInitial()) {
    _initializeMapController();
    _loadInitialAreas();
  }

  final MapService _mapService = MapService();
  late final MapController mapController;
  late LatLng latLngCenterPoint;
  late PolyEditor _polyEditor;
  PolygonExt? _hidePolygonOnEdit;

  /// Inicjalizuje `MapController` i nasłuchuje na środkowy punkt mapy.
  void _initializeMapController() {
    mapController = MapController();
    mapController.mapEventStream.listen((event) {
      latLngCenterPoint = event.camera.center;
    });
  }

  /// Ładuje początkowe obszary i
  ///  emituje je w stanie `MapViewControllerRefreshMap`.
  void _loadInitialAreas() {
    final areas = _mapService.loadAreas();
    emit(MapViewControllerRefreshMap(areas: areas, markers: const []));
  }

  /// Tworzy nowy wielokąt, którego pierwszy punkt to środek mapy.
  PolygonExt _createNewPolygon({
    required AreaType areaType,
    String? nestedUuid,
  }) {
    final uuid = const Uuid().v4();
    return PolygonExt(
      assignedMainArea: nestedUuid,
      type: areaType,
      color: areaType.color,
      hitValue: uuid,
      uuid: uuid,
      name: MapConfiguration.defaultPolygonName,
      description: MapConfiguration.defaultPolygonDescription,
      points: [latLngCenterPoint],
    );
  }

  /// Dodaje nowy wielokąt z punktem centralnym mapy.
  void addNewPolygon(AreaType areaType, String? nestedUuid) {
    final newPolygon =
        _createNewPolygon(areaType: areaType, nestedUuid: nestedUuid);
    final currentAreas = _getCurrentAreas();
    _initializePolygonEditor(
      polygonToEdit: newPolygon,
      currentAreas: currentAreas,
      mainUud: nestedUuid,
    );
  }

  /// Rozpoczyna edycję istniejącego wielokąta na podstawie jego UUID.
  /// Zapisuje zmiany, jeśli inny wielokąt jest aktualnie edytowany.
  void editExistingPolygon(String uuid) {
    final currentAreas = _getCurrentAreas();
    final mainUuid = currentAreas
        .firstWhere((element) => element.uuid == uuid)
        .assignedMainArea;
    final polygonToEdit =
        currentAreas.firstWhere((element) => element.uuid == uuid);
    mapController.move(
      LatLng(
        polygonToEdit.points.first.latitude,
        polygonToEdit.points.first.longitude,
      ),
      MapConfiguration.initialZoom,
    );

    _hideEditingElement(uuid);
    _initializePolygonEditor(
      polygonToEdit: polygonToEdit,
      currentAreas: currentAreas,
      mainUud: mainUuid,
    );
  }

  /// Ukrywa aktualnie edytowany wielokąt, aby edytor mógł operować
  /// na nowym wielokącie.
  void _hideEditingElement(String uuid) {
    final currentAreas = _getCurrentAreas();
    final polygonToEdit =
        currentAreas.firstWhere((element) => element.uuid == uuid);

    _hidePolygonOnEdit = polygonToEdit;
    currentAreas.removeWhere((element) => element.uuid == uuid);

    emit(
      MapViewControllerRefreshMap(
        areas: currentAreas,
        markers: const [],
        polygonToEdit: polygonToEdit,
      ),
    );
  }

  /// Inicjalizuje edytor wielokątów dla podanego wielokąta.
  void _initializePolygonEditor({
    required PolygonExt polygonToEdit,
    required List<PolygonExt> currentAreas,
    String? mainUud,
  }) {
    List<LatLng>? mainAreaPoint;

    try {
      mainAreaPoint =
          currentAreas.firstWhere((element) => element.uuid == mainUud).points;
    } catch (e) {
      mainAreaPoint = null; // Zwrócenie null, gdy nie ma dopasowania
    }

    _polyEditor = PolyEditor(
      intermediateIcon: MapConfiguration.intermediateIcon,
      pointIcon: MapConfiguration.pointIcon,
      points: List<LatLng>.from(polygonToEdit.points),
      onPointsUpdated: (updatedPoints, markers) {
        final hasErr = PolygonHelper.isPolygonInsidePolygon(
          updatedPoints,
          mainAreaPoint ?? [],
        );
        _onPointsUpdated(
          !hasErr,
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
        errorOnEdit: hasErr
            ? 'Polygon ${polygonToEdit.name} is outside of main area'
            : null,
      ),
    );
  }

  /// Emituje zaktualizowany stan mapy z nowymi markerami
  /// i edytowanym wielokątem.
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
  bool onPolygonTap(LayerHitResult<Object> hitResult) {
    final isEditingMode = (state as MapViewControllerRefreshMap).onEdit;
    if (isEditingMode) {
      return true;
    }
    final tapedUuid = hitResult.hitValues.firstOrNull as String?;
    if (tapedUuid != null) {
      editExistingPolygon(
        tapedUuid,
      );
    }
    return false;
  }

  /// Anuluje edycję aktualnego wielokąta i przywraca ukryty wielokąt.
  void cancelEditing() {
    final currentAreas = _getCurrentAreas();

    if (_hidePolygonOnEdit != null) {
      currentAreas.add(
        PolygonExt(
          uuid: _hidePolygonOnEdit!.uuid,
          name: _hidePolygonOnEdit!.name,
          description: _hidePolygonOnEdit!.description,
          points: List<LatLng>.from(_hidePolygonOnEdit!.points),
          color: _hidePolygonOnEdit!.color,
          type: _hidePolygonOnEdit!.type,
          assignedMainArea: _hidePolygonOnEdit!.assignedMainArea,
          hitValue: _hidePolygonOnEdit!.hitValue,
        ),
      );
      _hidePolygonOnEdit = null;
    }

    emit(MapViewControllerRefreshMap(areas: currentAreas, markers: const []));
  }

  /// Zapisuje nowy obszar i dodaje go do istniejącej listy obszarów.
  void saveNewArea() {
    final currentAreas = _getCurrentAreas();
    final newPolygon = _getPolygonToEdit();

    if (newPolygon == null) return;

    final updatedAreas = _createUpdatedAreas(currentAreas, newPolygon);
    emit(MapViewControllerRefreshMap(areas: updatedAreas, markers: const []));
  }

  /// Tworzy zaktualizowaną listę obszarów, dodając nowy wielokąt.
  List<PolygonExt> _createUpdatedAreas(
    List<PolygonExt> currentAreas,
    PolygonExt newPolygon,
  ) {
    return [
      ...currentAreas,
      newPolygon,
    ];
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
