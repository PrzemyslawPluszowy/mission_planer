import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mission_planer/features/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/features/map/entities/polygon_ext.dart';

class AllPolygon extends StatelessWidget {
  const AllPolygon({
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
