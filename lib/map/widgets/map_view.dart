import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:mission_planer/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/map/entities/area.dart';
import 'package:mission_planer/map/entities/polygon_ext.dart';
import 'package:mission_planer/map/services/map_configuration.dart';
import 'package:mission_planer/map/widgets/edit_bar.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final LayerHitNotifier hitNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapViewControllerCubit, MapViewControllerState>(
      builder: (context, state) {
        if (state is MapViewControllerRefreshMap) {
          return Stack(
            fit: StackFit.expand,
            children: [
              FlutterMap(
                mapController:
                    context.read<MapViewControllerCubit>().mapController,
                options: MapOptions(
                  onTap: (_, ll) {
                    /// Add point to polygon if in edit mode.
                    if (state.onEdit) {
                      context.read<MapViewControllerCubit>().addPoint(ll);
                    }
                  },
                  initialCenter: MapConfiguration.defaultStartLatLng,
                  initialZoom: MapConfiguration.initialZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: MapConfiguration.tileUrlTemplate,
                  ),

                  /// if edit mode is off and there are areas to display
                  LoadedPolygon(hitNotifier: hitNotifier, areas: state.areas),
                  if (state.onEdit && state.polygonToEdit != null)
                    EditedPolygon(polygonToEdit: state.polygonToEdit!),
                  DragMarkers(
                    markers: state.markers,
                  ),
                ],
              ),
              if (state.onEdit) const EditBar(),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class EditedPolygon extends StatelessWidget {
  const EditedPolygon({
    required this.polygonToEdit,
    super.key,
  });

  final PolygonExt polygonToEdit;

  @override
  Widget build(BuildContext context) {
    return PolygonLayer(
      polygons: [
        Polygon(
          points: polygonToEdit.points,
          color: MapConfiguration.defaultPolygonEdited,
        ),
      ],
    );
  }
}

class LoadedPolygon extends StatelessWidget {
  const LoadedPolygon({
    required this.hitNotifier,
    required this.areas,
    super.key,
  });

  final LayerHitNotifier<Object> hitNotifier;
  final List<Area> areas;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.deferToChild,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final hitResult = hitNotifier.value;
          if (hitResult != null) {
            final isEditingMode =
                context.read<MapViewControllerCubit>().onPolygonTap(hitResult);
            if (isEditingMode) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'MAsz aktywną edycję obszaru, zapisz lub anuluj zmiany',
                  ),
                ),
              );
            }
          }
        },
        child: PolygonLayer(
          hitNotifier: hitNotifier,
          polygons: areas.map((e) => e.polygon!).toList(),
        ),
      ),
    );
  }
}
