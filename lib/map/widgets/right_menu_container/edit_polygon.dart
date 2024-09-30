import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_planer/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/map/entities/polygon_ext.dart';

class EditPolygon extends StatelessWidget {
  const EditPolygon({
    required this.polygonToEdit,
    super.key,
  });
  final PolygonExt polygonToEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Edytowany obszar:'),
          const Divider(),
          TextFormField(
            onChanged: (value) =>
                context.read<MapViewControllerCubit>().changePolygonName(value),
            initialValue: polygonToEdit.name,
            decoration: const InputDecoration(
              labelText: 'Nazwa',
            ),
          ),
          TextFormField(
            onChanged: (value) => context
                .read<MapViewControllerCubit>()
                .changePolygonDescription(value),
            decoration: const InputDecoration(
              labelText: 'Opis',
            ),
            minLines: 1,
            maxLines: 5,
            initialValue: polygonToEdit.description,
          ),
        ],
      ),
    );
  }
}
