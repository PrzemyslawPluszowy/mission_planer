import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mission_planer/core/routing/routes.dart';
import 'package:mission_planer/features/map/view/map_view_screen.dart';
import 'package:mission_planer/features/rail_navigation/rail_routing.dart';
import 'package:mission_planer/features/setting/view/setting_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellSettingKey = GlobalKey<NavigatorState>();
final _shellMapPlanerKey = GlobalKey<NavigatorState>();
final GoRouter goRouter = GoRouter(
  initialLocation: '/map',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellMapPlanerKey,
          routes: [
            GoRoute(
              path: '/map',
              name: Routes.map,
              builder: (context, state) {
                return const MapViewScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellSettingKey,
          routes: [
            GoRoute(
              path: '/settings',
              name: Routes.settings,
              builder: (context, state) => const SettingScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
