import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_planer/core/extensions/context_text_theme.dart';
import 'package:mission_planer/core/extensions/l10n.dart';
import 'package:mission_planer/core/theme/app_sizes.dart';
import 'package:mission_planer/features/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/features/map/entities/polygon_ext.dart';
import 'package:mission_planer/features/map/services/map_configuration.dart';

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
            gapW8,
            BlocBuilder<MapViewControllerCubit, MapViewControllerState>(
              builder: (context, state) {
                if (state is MapViewControllerRefreshMap) {
                  if (state.polygonToEdit?.type == AreaType.mainArea) {
                    return SizedBox(
                      width: 150,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: context.l10n.maxFlyZone,
                        ),
                        initialValue: _findFancyAreaOffset(context),
                        onChanged: (value) {
                          final newValue = double.tryParse(value);
                          if (newValue != null) {
                            context
                                .read<MapViewControllerCubit>()
                                .offsetFancyArea = newValue;
                          }
                        },
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
            ),
            gapW8,
            const VerticalDivider(),
            _buildActionButton(
              context: context,
              icon: Icons.save,
              label: context.l10n.save,
              onPressed: () {
                final mapState = context.read<MapViewControllerCubit>().state
                    as MapViewControllerRefreshMap;

                if (mapState.errorOnEdit != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(mapState.errorOnEdit!.l10Message(context)),
                    ),
                  );
                } else {
                  context.read<MapViewControllerCubit>().saveNewArea();
                }
              },
            ),
            const VerticalDivider(),
            _buildActionButton(
              context: context,
              icon: Icons.clear,
              label: context.l10n.cancel,
              onPressed: () {
                context.read<MapViewControllerCubit>().cancelEditing();
              },
            ),
            const VerticalDivider(),
            _buildUndoButton(context),
            gapW8,
            const VerticalDivider(),
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
          Text(label, style: context.textTheme.bodyMedium),
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
            SnackBar(
              content: Text(context.l10n.cantDeleteStartPoint),
            ),
          );
        }
      },
      child: Row(
        children: [
          const Icon(
            Icons.undo,
          ),
          Text(
            context.l10n.deleteLastPoint,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _findFancyAreaOffset(BuildContext context) {
    final fancyArea = context
        .read<MapViewControllerCubit>()
        .hidePolygonsOnEdit
        ?.firstWhereOrNull(
          (element) => element.type == AreaType.fancyArea,
        );
    if (fancyArea != null) {
      return fancyArea.offset.toString();
    } else {
      return '0';
    }
  }
}
