import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recipe_model.dart';
import '../models/recipe_type_model.dart';

class RecipeService {
  static const String _recipeBoxName = 'recipes';
  static Box<Recipe>? _recipeBox;

  // Initialize Hive and open the box
  static Future<void> initialize() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    
    // Register adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecipeAdapter());
    }
    
    // Open box
    _recipeBox = await Hive.openBox<Recipe>(_recipeBoxName);
    
    // Pre-populate with sample data if box is empty
    if (_recipeBox!.isEmpty) {
      await _populateSampleRecipes();
    }
  }

  // Get the recipe box
  static Box<Recipe> get recipeBox {
    if (_recipeBox == null || !_recipeBox!.isOpen) {
      throw Exception('Recipe box is not initialized. Call initialize() first.');
    }
    return _recipeBox!;
  }

  // Load recipe types from JSON
  static Future<List<RecipeType>> loadRecipeTypes() async {
    try {
      final jsonString = await rootBundle.loadString('assets/recipetypes.json');
      return RecipeType.listFromJson(jsonString);
    } catch (e) {
      throw Exception('Failed to load recipe types: $e');
    }
  }

  // Create a new recipe
  static Future<void> createRecipe(Recipe recipe) async {
    await recipeBox.put(recipe.id, recipe);
  }

  // Get all recipes
  static List<Recipe> getAllRecipes() {
    return recipeBox.values.toList();
  }

  // Get recipe by ID
  static Recipe? getRecipeById(String id) {
    return recipeBox.get(id);
  }

  // Update recipe
  static Future<void> updateRecipe(Recipe recipe) async {
    await recipeBox.put(recipe.id, recipe);
  }

  // Delete recipe
  static Future<void> deleteRecipe(String id) async {
    // Delete associated image file if exists
    final recipe = recipeBox.get(id);
    if (recipe?.imagePath != null && recipe!.imagePath!.isNotEmpty) {
      try {
        final imageFile = File(recipe.imagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      } catch (e) {
        // Continue with deletion even if image deletion fails
      }
    }
    await recipeBox.delete(id);
  }

  // Filter recipes by type
  static List<Recipe> getRecipesByType(int typeId) {
    return recipeBox.values.where((recipe) => recipe.recipeTypeId == typeId).toList();
  }

  // Pre-populate sample recipes
  static Future<void> _populateSampleRecipes() async {
    final sampleRecipes = [
      Recipe(
        id: '1',
        name: 'Classic Pancakes',
        recipeTypeId: 1,
        recipeTypeName: 'Breakfast',
        ingredients: [
          '1 cup all-purpose flour',
          '2 tablespoons sugar',
          '2 teaspoons baking powder',
          '1/2 teaspoon salt',
          '1 cup milk',
          '1 egg',
          '2 tablespoons melted butter',
        ],
        steps: [
          'Mix dry ingredients in a bowl',
          'Whisk together milk, egg, and melted butter',
          'Combine wet and dry ingredients',
          'Heat a griddle over medium heat',
          'Pour 1/4 cup batter for each pancake',
          'Cook until bubbles form, then flip',
          'Cook until golden brown on both sides',
        ],
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: '2',
        name: 'Caesar Salad',
        recipeTypeId: 2,
        recipeTypeName: 'Lunch',
        ingredients: [
          '1 head romaine lettuce',
          '1/2 cup Caesar dressing',
          '1/2 cup croutons',
          '1/4 cup parmesan cheese',
          '2 grilled chicken breasts (optional)',
        ],
        steps: [
          'Wash and chop romaine lettuce',
          'Slice grilled chicken if using',
          'Place lettuce in a large bowl',
          'Add Caesar dressing and toss well',
          'Top with croutons and parmesan cheese',
          'Add chicken if desired',
          'Serve immediately',
        ],
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: '3',
        name: 'Spaghetti Carbonara',
        recipeTypeId: 3,
        recipeTypeName: 'Dinner',
        ingredients: [
          '400g spaghetti',
          '200g bacon or pancetta',
          '4 eggs',
          '100g parmesan cheese',
          'Black pepper',
          'Salt',
        ],
        steps: [
          'Cook spaghetti according to package directions',
          'Fry bacon until crispy, then chop',
          'Beat eggs and mix with parmesan cheese',
          'Drain pasta, reserving 1 cup pasta water',
          'Add hot pasta to bacon',
          'Remove from heat and quickly stir in egg mixture',
          'Add pasta water to reach desired consistency',
          'Season with black pepper and serve',
        ],
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: '4',
        name: 'Chocolate Chip Cookies',
        recipeTypeId: 4,
        recipeTypeName: 'Dessert',
        ingredients: [
          '2 1/4 cups all-purpose flour',
          '1 tsp baking soda',
          '1 cup butter, softened',
          '3/4 cup sugar',
          '3/4 cup brown sugar',
          '2 eggs',
          '2 tsp vanilla extract',
          '2 cups chocolate chips',
        ],
        steps: [
          'Preheat oven to 375°F (190°C)',
          'Mix flour and baking soda',
          'Cream together butter and sugars',
          'Beat in eggs and vanilla',
          'Gradually blend in flour mixture',
          'Stir in chocolate chips',
          'Drop rounded tablespoons onto baking sheets',
          'Bake for 9-11 minutes until golden brown',
        ],
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: '5',
        name: 'Fresh Fruit Smoothie',
        recipeTypeId: 6,
        recipeTypeName: 'Beverage',
        ingredients: [
          '1 banana',
          '1 cup strawberries',
          '1/2 cup blueberries',
          '1 cup yogurt',
          '1/2 cup orange juice',
          '1 tablespoon honey',
          'Ice cubes',
        ],
        steps: [
          'Add all fruits to blender',
          'Add yogurt and orange juice',
          'Add honey and ice cubes',
          'Blend until smooth',
          'Pour into glasses and serve immediately',
        ],
        createdAt: DateTime.now(),
      ),
    ];

    for (final recipe in sampleRecipes) {
      await createRecipe(recipe);
    }
  }

  // Close the box (call when app is closed)
  static Future<void> close() async {
    await _recipeBox?.close();
  }
}
