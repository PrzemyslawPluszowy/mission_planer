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
        return _buildExpansionTile(context, mappedAreas[index]);
      },
    );
  }

  // Metoda tworząca główny kafelek obszaru z rozwijaną listą sub-obszarów
  Widget _buildExpansionTile(BuildContext context, MappedArea mappedArea) {
    return ExpansionTile(
      dense: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => context
                .read<MapViewControllerCubit>()
                .editExistingPolygon(mappedArea.mainPolygon),
            icon: const Icon(Icons.edit_location_alt),
          ),
          IconButton(
            onPressed: () =>
                context.read<MapViewControllerCubit>().deletePolygon(
                      mappedArea.mainPolygon.uuid,
                      mappedArea.mainPolygon.type,
                    ),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      title: Text(
        mappedArea.mainPolygon.name,
        style: const TextStyle(fontSize: 12),
      ),
      subtitle: Text(
        mappedArea.mainPolygon.description,
        style: const TextStyle(fontSize: 10),
      ),
      children: [
        ..._buildSubAreaTiles(context, mappedArea),
        Center(
          child: Column(
            children: [
              _buildAddNewAreaRow(
                context,
                mappedArea.mainPolygon.uuid,
                AreaType.subArea,
                'Dodaj nowy podobszar',
              ),
              _buildAddNewAreaRow(
                context,
                mappedArea.mainPolygon.uuid,
                AreaType.noFlyZone,
                'Dodaj nową strefę zakazu',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Metoda tworząca listę sub-obszarów
  List<Widget> _buildSubAreaTiles(BuildContext context, MappedArea mappedArea) {
    return mappedArea.subPolygons.map((subArea) {
      return ListTile(
        leading: _selectIcon(subArea.type),
        dense: true,
        trailing: _buildEditAndDeleteButtons(context, subArea),
        contentPadding: const EdgeInsets.only(left: 20, right: 10),
        title: Text(
          subArea.type != AreaType.fancyArea
              ? subArea.name
              : 'Strefa buforowa (${subArea.offset.toStringAsFixed(0)}m)',
          style: const TextStyle(fontSize: 10),
        ),
        subtitle: Text(
          subArea.description,
          style: const TextStyle(fontSize: 8),
        ),
      );
    }).toList();
  }

  // Metoda tworząca dodawanie nowych obszarów
  Widget _buildAddNewAreaRow(
    BuildContext context,
    String uuid,
    AreaType areaType,
    String label,
  ) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context
              .read<MapViewControllerCubit>()
              .addNewPolygon(areaType, uuid),
          icon: const Icon(Icons.add_box_rounded),
        ),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  // Metoda tworząca przyciski edycji i usuwania
  Widget _buildEditAndDeleteButtons(BuildContext context, PolygonExt area) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (area.type != AreaType.fancyArea)
          IconButton(
            onPressed: () => context
                .read<MapViewControllerCubit>()
                .editExistingPolygon(area),
            icon: const Icon(Icons.edit_location_alt),
          ),
        if (area.type != AreaType.fancyArea)
          IconButton(
            onPressed: () => context
                .read<MapViewControllerCubit>()
                .deletePolygon(area.uuid, area.type),
            icon: const Icon(Icons.delete),
          ),
      ],
    );
  }

  Icon _selectIcon(AreaType type) {
    switch (type) {
      case AreaType.mainArea:
      case AreaType.subArea:
        return const Icon(Icons.label);
      case AreaType.noFlyZone:
        return const Icon(Icons.warning);
      case AreaType.fancyArea:
        return const Icon(Icons.map);
    }
  }
}
