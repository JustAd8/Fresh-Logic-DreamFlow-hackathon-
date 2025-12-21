import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fridgeflow/widgets/bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
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
        },
      ),
    );
  }
}
