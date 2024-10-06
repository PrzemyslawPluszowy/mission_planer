import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mission_planer/core/extensions/context_color.dart';
import 'package:mission_planer/core/theme/app_sizes.dart';
import 'package:mission_planer/features/map/cubit/map_style_cubit.dart';
import 'package:mission_planer/features/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/features/map/entities/polygon_ext.dart';
import 'package:mission_planer/features/map/services/map_configuration.dart';
import 'package:mission_planer/features/map/widgets/all_polygon.dart';
import 'package:mission_planer/features/map/widgets/edit_bar.dart';

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
                    ///  dodaje punkt do edycji
                    if (state.onEdit) {
                      context.read<MapViewControllerCubit>().addPoint(ll);
                    }
                  },
                  initialCenter: MapConfiguration.defaultStartLatLng,
                  initialZoom: MapConfiguration.initialZoom,
                ),
                children: [
                  BlocBuilder<MapStyleCubit, MapStyleState>(
                    builder: (context, state) {
                      return TileLayer(
                        urlTemplate: state.mapStyle.getTemplateUrl(),
                      );
                    },
                  ),
                  //załadowane z bakendu polygony
                  AllPolygon(
                    hitNotifier: hitNotifier,
                    areas: state.areas,
                    useOnEditingMode: state.onEdit,
                  ),

                  //pokazuje edytowalny polygon oraz punkty do edycji
                  if (state.onEdit && state.polygonToEdit != null)
                    EditedPolygon(polygonToEdit: state.polygonToEdit!),
                  DragMarkers(
                    markers: state.markers,
                  ),
                ],
              ),
              //pokazuje pasek edycji
              if (state.onEdit) const EditBar(),
              if (state.errorOnEdit != null) _errorEditingArea(state),
              Positioned(
                bottom: 50,
                right: 30,
                child: FloatingActionButton(
                  onPressed: () {
                    context.read<MapStyleCubit>().changeStyle();
                  },
                  child: Icon(
                    Ionicons.map,
                    color: context.colorScheme.onInverseSurface,
                  ),
                ),
              ),
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
        padding: const EdgeInsets.all(Sizes.p8),
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
            state.errorOnEdit!.l10Message(context),
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
