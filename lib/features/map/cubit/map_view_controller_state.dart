part of 'map_view_controller_cubit.dart';

@immutable
sealed class MapViewControllerState {}

final class MapViewControllerInitial extends MapViewControllerState {}

final class MapViewControllerRefreshMap extends MapViewControllerState {
  MapViewControllerRefreshMap({
    required this.markers,
    required this.areas,
    this.onEdit = false,
    this.polygonToEdit,
    this.errorOnEdit,
  });
  final List<PolygonExt> areas;
  final bool onEdit;
  final PolygonExt? polygonToEdit;
  final List<DragMarker> markers;
  final String? errorOnEdit;
}
