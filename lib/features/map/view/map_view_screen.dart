import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_planer/features/map/cubit/map_style_cubit.dart';
import 'package:mission_planer/features/map/cubit/map_view_controller_cubit.dart';
import 'package:mission_planer/features/map/widgets/map_view.dart';
import 'package:mission_planer/features/map/widgets/right_menu_container/right_menu_container.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<MapViewControllerCubit>(
            create: (context) => MapViewControllerCubit(),
          ),
          BlocProvider(create: (context) => MapStyleCubit()),
        ],
        child: const Row(
          children: [
            Expanded(
              child: MapView(),
            ),
            RightMenuContainer(),
          ],
        ),
      ),
    );
  }
}
