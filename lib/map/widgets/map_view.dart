import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:mission_planer/map/cubit/map_view_controller_cubit.dart';
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
                  ///
                  LoadedPolygon(
                    hitNotifier: hitNotifier,
                    areas: state.areas,
                    useOnEditingMode: state.onEdit,
                  ),
                  if (state.onEdit && state.polygonToEdit != null)
                    EditedPolygon(polygonToEdit: state.polygonToEdit!),

                  DragMarkers(
                    markers: state.markers,
                  ),
                ],
              ),
              if (state.onEdit) const EditBar(),
              if (state.errorOnEdit != null) _errorEditingArea(state),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Positioned _errorEditingArea(MapViewControllerRefreshMap state) {
    return Positioned(
      top: 100,
      left: 0,
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(
          minWidth: 300,
        ),
        height: MapConfiguration.editBarHeight,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          color: Color.fromARGB(255, 255, 17, 0),
        ),
        child: Center(
          child: Text(
            state.errorOnEdit!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      )
          .animate()
          .moveX(
            begin: -1000,
            end: 0,
          )
          .fade(
            duration: const Duration(milliseconds: 1000),
          ),
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
        polygonToEdit,
      ],
    );
  }
}

class LoadedPolygon extends StatelessWidget {
  const LoadedPolygon({
    required this.hitNotifier,
    required this.areas,
    required this.useOnEditingMode,
    super.key,
  });

  final LayerHitNotifier<Object> hitNotifier;
  final List<PolygonExt> areas;
  final bool useOnEditingMode;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.deferToChild,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: useOnEditingMode
            ? null
            : () {
                final hitResult = hitNotifier.value;
                if (hitResult != null) {
                  context
                      .read<MapViewControllerCubit>()
                      .onPolygonTap(hitResult);
                }
              },
        child: PolygonLayer(
          hitNotifier: hitNotifier,
          polygons: areas,
        ),
      ),
    );
  }
}
