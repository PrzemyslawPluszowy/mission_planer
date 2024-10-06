import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_planer/core/theme/app_sizes.dart';
import 'package:mission_planer/features/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/features/map/widgets/right_menu_container/add_b_t_n.dart';
import 'package:mission_planer/features/map/widgets/right_menu_container/edit_polygon.dart';
import 'package:mission_planer/features/map/widgets/right_menu_container/list_areas.dart';

class RightMenuContainer extends StatelessWidget {
  const RightMenuContainer({super.key});

  static const _rightMenuWidth = 300.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: _rightMenuWidth,
      height: double.infinity,
      child: BlocBuilder<MapViewControllerCubit, MapViewControllerState>(
        builder: (context, state) {
          if (state is MapViewControllerRefreshMap) {
            return Column(
              children: [
                gapH20,
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
