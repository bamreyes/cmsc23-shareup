import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class ScaffoldLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldLayout({required this.navigationShell, Key? key})
      : super(key: key ?? const ValueKey<String>('ScaffoldLayout'));

  @override
  State<ScaffoldLayout> createState() => _ScaffoldLayoutState();
}

class _ScaffoldLayoutState extends State<ScaffoldLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().updateLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: widget.navigationShell.goBranch,
          destinations: destinations
              .map(
                (destination) => NavigationDestination(
                  icon: Icon(destination.icon),
                  label: destination.label,
                  selectedIcon: Icon(destination.selectedIcon),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class Destination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

const destinations = [
  Destination(
    label: "Home",
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  Destination(
    label: "Feed",
    icon: Icons.shopping_basket_outlined,
    selectedIcon: Icons.shopping_basket,
  ),
  Destination(
    label: "Exchanges",
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
  ),
  Destination(
    label: "Profile",
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];
