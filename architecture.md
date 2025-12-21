# FridgeFlow Architecture

## Overview
FridgeFlow is an intelligent kitchen operating system that manages inventory, reduces food waste via expiry tracking, generates AI recipes based on available stock, and automates restocking via quick commerce.

## Design System
- **Style**: Modern, Clean, Eco-Friendly Tech
- **Color Palette**: 
  - Primary: Sage Green (#7C9A7F)
  - Secondary: Charcoal (#2C3333)
  - Alert: Soft Red (#E57373) for expired items
- **Typography**: Inter font family for high readability
- **Layout**: Card-based interfaces, bottom navigation, ample whitespace

## Data Models
All models stored in `lib/models/`:

1. **User** (`user_model.dart`)
   - Fields: id, name, email, dietaryPreferences, allergies, createdAt, updatedAt
   - Methods: toJson, fromJson, copyWith

2. **InventoryItem** (`inventory_item_model.dart`)
   - Fields: id, userId, itemName, quantity, unit, purchaseDate, expiryDate, category, imageUrl, createdAt, updatedAt
   - Computed: daysRemaining (expiryDate - currentDate)
   - Categories: Produce, Dairy, Meat, Grains, Beverages, Condiments, Frozen, Other
   - Methods: toJson, fromJson, copyWith

3. **Recipe** (`recipe_model.dart`)
   - Fields: id, title, ingredientsRequired, missingIngredients, instructions, cookingTime, heroImage, matchScore, createdAt
   - Methods: toJson, fromJson, copyWith

4. **ShoppingCart** (`shopping_cart_model.dart`)
   - Fields: id, userId, items (list of CartItem), status, createdAt, updatedAt
   - Status: active, ordered
   - Methods: toJson, fromJson, copyWith

## Service Layer
All services in `lib/services/` with local storage using shared_preferences:

1. **UserService** (`user_service.dart`)
   - Singleton pattern
   - Manages current user and dietary preferences
   - Persists to local storage

2. **InventoryService** (`inventory_service.dart`)
   - CRUD operations for inventory items
   - IoT sync simulation (bulk adds random items)
   - Expiry filtering and sorting
   - Sample data for demo purposes
   - All operations filtered by userId

3. **RecipeService** (`recipe_service.dart`)
   - AI recipe generation (placeholder for OpenAI/Claude)
   - Gap analysis (have vs need ingredients)
   - Match score calculation
   - Sample recipes

4. **ShoppingCartService** (`shopping_cart_service.dart`)
   - Cart management
   - Deep-link generation for quick commerce
   - All operations filtered by userId

## Screen Architecture
Bottom navigation with 4 main tabs:

1. **Dashboard Screen** (`/`) - `lib/screens/dashboard_screen.dart`
   - FreshnessGauge widget showing pantry health
   - Expiring soon section (items < 3 days)
   - Suggested dinner based on available stock
   - Quick action buttons

2. **Smart Pantry Screen** (`/pantry`) - `lib/screens/pantry_screen.dart`
   - Grid view of inventory items
   - Sorted by daysRemaining (ascending)
   - Color-coded expiry indicators
   - IoT sync button (adds 5 random items)
   - Add/Edit/Delete functionality

3. **Recipes Screen** (`/recipes`) - `lib/screens/recipes_screen.dart`
   - Generate recipes based on inventory
   - Recipe cards with match scores
   - Ingredient breakdown (have vs need)
   - Add missing ingredients to cart

4. **Shop Screen** (`/shop`) - `lib/screens/shop_screen.dart`
   - Shopping cart view
   - One-click restock via deep-link
   - Cart management

5. **Cooking Mode Screen** (`/cooking/:recipeId`) - `lib/screens/cooking_mode_screen.dart`
   - Large text step-by-step instructions
   - Text-to-speech integration (placeholder)
   - Step navigation

6. **Onboarding Screen** (`/onboarding`) - `lib/screens/onboarding_screen.dart`
   - First-run experience
   - Dietary preferences selection
   - Allergies input

## Reusable Components
Located in `lib/widgets/`:

1. **FreshnessGauge** - Circular progress indicator for pantry health
2. **InventoryItemCard** - Card with dynamic border colors based on expiry
3. **RecipeCard** - Shows recipe with match score and ingredients
4. **BottomNavBar** - Custom bottom navigation with icons
5. **ExpiryBadge** - Visual indicator for expiry status

## State Management
- Provider for global state
- Providers: UserProvider, InventoryProvider, RecipeProvider, CartProvider
- Located in `lib/providers/`

## Navigation
- go_router configuration in `lib/nav.dart`
- Deep linking support
- Bottom tab persistence via ShellRoute

## Security & Scalability
- All database queries filtered by userId
- Component-based architecture for reusability
- Offline-first with local storage
- Ready for infinite scroll implementation
- Type-safe navigation with go_router

## Future Enhancements
- Real Firebase/Supabase backend integration
- OpenAI/Claude API for recipe generation
- ElevenLabs TTS for cooking mode
- IoT device integration for automatic inventory sync
- Push notifications for expiring items
- Barcode scanning for quick item entry
