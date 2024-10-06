import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mission_planer/core/extensions/context_color.dart';
import 'package:mission_planer/core/extensions/l10n.dart';

enum BottomRouting implements Comparable<BottomRouting> {
  map,
  settings;

  const BottomRouting();

  String getName(BuildContext context) {
    switch (this) {
      case BottomRouting.map:
        return context.l10n.mapPlaner;

      case BottomRouting.settings:
        return context.l10n.settings;
    }
  }

  IconData getIcon() {
    switch (this) {
      case BottomRouting.map:
        return Icons.people;

      case BottomRouting.settings:
        return Icons.settings;
    }
  }

  IconData getSelectedIcon() {
    switch (this) {
      case BottomRouting.map:
        return Icons.people_alt_outlined;

      case BottomRouting.settings:
        return Icons.settings;
    }
  }

  @override
  int compareTo(BottomRouting other) {
    return index.compareTo(other.index);
  }
}

class NavigationLayout extends StatefulWidget {
  const NavigationLayout({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<NavigationLayout> createState() => _NavigationLayoutState();
}

class _NavigationLayoutState extends State<NavigationLayout> {
  final canSwitch = ValueNotifier<bool>(true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: context.colorScheme.surfaceContainer,
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (index) {
              widget.navigationShell.goBranch(index);
            },
            labelType: NavigationRailLabelType.selected,
            destinations: BottomRouting.values.map((route) {
              return NavigationRailDestination(
                icon: Icon(route.getIcon()),
                selectedIcon: Icon(route.getSelectedIcon()),
                label: Text(route.getName(context)),
              );
            }).toList(),
          ),
          Expanded(
            child: widget.navigationShell,
          ),
        ],
      ),
    );
  }
}
