import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_planer/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/map/entities/polygon_ext.dart';
import 'package:mission_planer/map/services/polygon_helper.dart';

class ListAreas extends StatelessWidget {
  const ListAreas({
    required this.areas,
    super.key,
  });
  final List<PolygonExt> areas;

  @override
  Widget build(BuildContext context) {
    final mappedAreas = PolygonHelper.mapToSubAreas(areas);
    return ListView.builder(
      itemCount: mappedAreas.length,
      itemBuilder: (context, index) {
        return ExpansionTile(
          dense: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => context
                    .read<MapViewControllerCubit>()
                    .editExistingPolygon(areas[index].uuid),
                icon: const Icon(Icons.edit_location_alt),
              ),
              IconButton(
                onPressed: () => context
                    .read<MapViewControllerCubit>()
                    .deletePolygon(areas[index].uuid, areas[index].type),
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          title: Text(
            areas[index].name,
            style: const TextStyle(fontSize: 12),
          ),
          subtitle: Text(
            areas[index].description,
            style: const TextStyle(fontSize: 10),
          ),
          children: [
            for (final subArea in mappedAreas[index].subPolygons)
              ListTile(
                leading: subArea.type == AreaType.subArea
                    ? const Icon(Icons.label)
                    : const Icon(Icons.warning),
                dense: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => context
                          .read<MapViewControllerCubit>()
                          .editExistingPolygon(subArea.uuid),
                      icon: const Icon(Icons.edit_location_alt),
                    ),
                    IconButton(
                      onPressed: () => context
                          .read<MapViewControllerCubit>()
                          .deletePolygon(subArea.uuid, subArea.type),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.only(left: 20, right: 10),
                title: Text(
                  subArea.name,
                  style: const TextStyle(fontSize: 10),
                ),
                subtitle: Text(
                  subArea.description,
                  style: const TextStyle(fontSize: 8),
                ),
              ),
            Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context
                            .read<MapViewControllerCubit>()
                            .addNewPolygon(AreaType.subArea, areas[index].uuid),
                        icon: const Icon(Icons.add_box_rounded),
                      ),
                      const Text(
                        'Dodaj nowy podobszar',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context
                            .read<MapViewControllerCubit>()
                            .addNewPolygon(
                              AreaType.noFlyZone,
                              areas[index].uuid,
                            ),
                        icon: const Icon(Icons.add_box_rounded),
                      ),
                      const Text(
                        'Dodaj  nową strefę zakazu',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
