import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fridgeflow/widgets/bottom_nav_bar.dart';
import 'package:fridgeflow/utils/responsive_layout.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/pantry');
        break;
      case 2:
        context.go('/recipes');
        break;
      case 3:
        context.go('/shop');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showNavigationRail = ResponsiveLayout.shouldShowNavigationRail(context);

    if (showNavigationRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => _navigate(context, index),
              labelType: ResponsiveLayout.isDesktop(context)
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.selected,
              backgroundColor: Theme.of(context).colorScheme.surface,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.kitchen_outlined),
                  selectedIcon: Icon(Icons.kitchen),
                  label: Text('Pantry'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(Icons.restaurant_menu),
                  label: Text('Recipes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart),
                  label: Text('Shop'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _navigate(context, index),
      ),
    );
  }
}
