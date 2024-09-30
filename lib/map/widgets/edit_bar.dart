import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_planer/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/map/services/map_configuration.dart';

class EditBar extends StatelessWidget {
  const EditBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MapConfiguration.editBarHeight,
        decoration: MapConfiguration.editBarDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildActionButton(
              context: context,
              icon: Icons.save,
              label: 'Zapisz zmiany',
              onPressed: () {
                context.read<MapViewControllerCubit>().saveNewArea();
              },
            ),
            const VerticalDivider(),
            _buildActionButton(
              context: context,
              icon: Icons.clear,
              label: 'Anuluj',
              onPressed: () {
                context.read<MapViewControllerCubit>().cancelEditing();
              },
            ),
            const VerticalDivider(),
            _buildUndoButton(context),
            const SizedBox(width: 8),
            const VerticalDivider(width: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildUndoButton(BuildContext context) {
    return InkWell(
      onTap: () {
        final canUndo =
            context.read<MapViewControllerCubit>().undoCreatedPoints();
        if (!canUndo) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nie można usunąć punktu startowego'),
            ),
          );
        }
      },
      child: const Row(
        children: [
          Icon(
            Icons.undo,
          ),
          Text('Cofnij ostatni punkt', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
