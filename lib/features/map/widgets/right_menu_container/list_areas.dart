import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_planer/core/extensions/context_text_theme.dart';
import 'package:mission_planer/core/extensions/l10n.dart';
import 'package:mission_planer/core/theme/app_sizes.dart';
import 'package:mission_planer/features/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/features/map/entities/mapped_area.dart';
import 'package:mission_planer/features/map/entities/polygon_ext.dart';
import 'package:mission_planer/features/map/services/map_configuration.dart';

class ListAreas extends StatelessWidget {
  const ListAreas({
    required this.areas,
    super.key,
  });
  final List<PolygonExt> areas;

  @override
  Widget build(BuildContext context) {
    final mappedAreas = MappedArea.mapToSubAreas(areas);
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
            icon: const Icon(Icons.edit_location_alt, size: Sizes.p16),
          ),
          IconButton(
            onPressed: () =>
                context.read<MapViewControllerCubit>().deletePolygon(
                      mappedArea.mainPolygon.uuid,
                      mappedArea.mainPolygon.type,
                    ),
            icon: const Icon(Icons.delete, size: Sizes.p16),
          ),
          IconButton(
            onPressed: () =>
                context.read<MapViewControllerCubit>().mapController.move(
                      mappedArea.mainPolygon.points.first,
                      MapConfiguration.initialZoom,
                    ),
            icon: const Icon(Icons.pin_drop, size: Sizes.p16),
          ),
        ],
      ),
      title: Text(
        mappedArea.mainPolygon.name,
        style: context.textTheme.bodyMedium,
      ),
      subtitle: Text(
        mappedArea.mainPolygon.description,
        style: context.textTheme.bodySmall,
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
                context.l10n.addSubArea,
              ),
              _buildAddNewAreaRow(
                context,
                mappedArea.mainPolygon.uuid,
                AreaType.noFlyZone,
                context.l10n.addRestrictedArea,
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
        leading: Icon(_selectIcon(subArea.type).icon, color: subArea.color),
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
          onPressed: () => context.read<MapViewControllerCubit>().addNewPolygon(
                areaType,
                uuid,
                areaType == AreaType.noFlyZone
                    ? Colors.red.withOpacity(0.3)
                    : randomColor(),
              ),
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

  Color randomColor() {
    return Colors.primaries[Random().nextInt(Colors.primaries.length)]
        .withOpacity(0.5);
  }
}
