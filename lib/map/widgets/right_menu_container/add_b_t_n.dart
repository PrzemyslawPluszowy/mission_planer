import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_planer/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/map/entities/polygon_ext.dart';

class AddBTN extends StatelessWidget {
  const AddBTN({
    required this.onEdit,
    super.key,
  });
  final bool onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onEdit
              ? null
              : () => context
                  .read<MapViewControllerCubit>()
                  .addNewPolygon(AreaType.mainArea, null),
          icon: const Icon(Icons.add_box_rounded),
        ),
        const Text(
          'Dodaj nowy obszar',
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
