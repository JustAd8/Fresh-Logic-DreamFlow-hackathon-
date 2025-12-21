import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fridgeflow/firebase_options.dart';
import 'package:fridgeflow/theme.dart';
import 'package:fridgeflow/nav.dart';
import 'package:fridgeflow/services/user_service.dart';
import 'package:fridgeflow/services/inventory_service.dart';
import 'package:fridgeflow/services/recipe_service.dart';
import 'package:fridgeflow/services/shopping_cart_service.dart';

/// Main entry point for FridgeFlow
///
/// Initializes all services and sets up the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initializeServices();
  
  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await UserService().initialize();
    
    final user = UserService().currentUser;
    if (user != null) {
      await InventoryService().initialize(user.id);
      await RecipeService().initialize(user.id);
      await ShoppingCartService().initialize(user.id);
      
      if (RecipeService().recipes.isEmpty) {
        final availableItems = InventoryService().getItemsByUserId(user.id);
        await RecipeService().generateRecipes(availableItems);
      }
    }
  } catch (e) {
    debugPrint('Failed to initialize services: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FridgeFlow',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
