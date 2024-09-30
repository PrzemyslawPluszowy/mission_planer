import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_planer/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/map/entities/area.dart';
import 'package:mission_planer/map/entities/polygon_ext.dart';

class RightMenuContainer extends StatelessWidget {
  const RightMenuContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 300,
      height: double.infinity,
      child: BlocBuilder<MapViewControllerCubit, MapViewControllerState>(
        builder: (context, state) {
          if (state is MapViewControllerRefreshMap) {
            return Column(
              children: [
                const SizedBox(height: 20),
                AddBTN(onEdit: state.onEdit),
                const Divider(),
                if (state.onEdit)
                  EditPolygon(polygonToEdit: state.polygonToEdit!),
                if (!state.onEdit)
                  Expanded(
                    child: ListAreas(areas: state.areas),
                  ),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class ListAreas extends StatelessWidget {
  const ListAreas({
    required this.areas,
    super.key,
  });
  final List<Area> areas;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: areas.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => context
              .read<MapViewControllerCubit>()
              .editExistingPolygon(areas[index].uuid),
          child: ListTile(
            title: Text(
              areas[index].name,
              style: const TextStyle(fontSize: 12),
            ),
            subtitle: Text(
              areas[index].description,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        );
      },
    );
  }
}

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
              : () => context.read<MapViewControllerCubit>().addNewPolygon(),
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
