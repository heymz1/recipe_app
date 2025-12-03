import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/recipe_model.dart';
import '../models/recipe_type_model.dart';

// Service for handling all recipe operations with SQLite
class RecipeService {
  static Database? _db;

  // init database
  static Future<void> init() async {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    var dbPath = await getDatabasesPath();
    String path = join(dbPath, 'recipes.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // create recipes table
        await db.execute('''
          CREATE TABLE recipes (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            typeId INTEGER NOT NULL,
            typeName TEXT NOT NULL,
            imgPath TEXT,
            ingredients TEXT NOT NULL,
            steps TEXT NOT NULL,
            createdAt INTEGER NOT NULL
          )
        ''');
      },
    );

    // add sample data if empty
    var count = await _db!.rawQuery('SELECT COUNT(*) as count FROM recipes');
    if (count[0]['count'] == 0) {
      await addSampleData();
    } else {
      // Migration: add images to existing sample recipes
      await _migrateExistingRecipes();
    }
  }

  static Database get db => _db!;

  // load types from json file
  static Future<List<RecipeType>> getTypes() async {
    var jsonString = await rootBundle.loadString('assets/recipetypes.json');
    return RecipeType.parseJson(jsonString);
  }

  // CRUD operations
  static Future<void> addRecipe(Recipe r) async {
    await db.insert('recipes', r.toMap());
  }

  static Future<List<Recipe>> getAll() async {
    var maps = await db.query('recipes', orderBy: 'createdAt DESC');
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  static Future<Recipe?> getById(String id) async {
    var maps = await db.query('recipes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Recipe.fromMap(maps.first);
  }

  static Future<void> update(Recipe r) async {
    await db.update('recipes', r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  static Future<void> delete(String id) async {
    // get recipe first to delete image
    var recipe = await getById(id);
    if (recipe?.imgPath != null && recipe!.imgPath!.isNotEmpty) {
      try {
        var file = File(recipe.imgPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // ignore
      }
    }
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  // filter by type
  static Future<List<Recipe>> filterByType(int typeId) async {
    var maps = await db.query(
      'recipes',
      where: 'typeId = ?',
      whereArgs: [typeId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => Recipe.fromMap(m)).toList();
  }

  // add some sample recipes
  static Future<void> addSampleData() async {
    // Get the application documents directory for storing images
    var appDir = await getDatabasesPath();
    var imagesDir = join(appDir, 'recipe_images');

    // Create images directory if it doesn't exist
    var dir = Directory(imagesDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    var samples = [
      Recipe(
        id: '1',
        name: 'Pancakes',
        typeId: 1,
        typeName: 'Breakfast',
        imgPath: null,
        ingredients: Recipe.joinList([
          '1 cup flour',
          '2 tbsp sugar',
          '2 tsp baking powder',
          '1/2 tsp salt',
          '1 cup milk',
          '1 egg',
          '2 tbsp butter',
        ]),
        steps: Recipe.joinList([
          'Mix dry ingredients',
          'Mix wet ingredients',
          'Combine everything',
          'Heat pan',
          'Pour batter',
          'Flip when bubbles form',
          'Cook until golden',
        ]),
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: '2',
        name: 'Caesar Salad',
        typeId: 2,
        typeName: 'Lunch',
        imgPath: null, // User can add image later
        ingredients: Recipe.joinList([
          'Romaine lettuce',
          'Caesar dressing',
          'Croutons',
          'Parmesan',
          'Chicken (optional)',
        ]),
        steps: Recipe.joinList([
          'Wash lettuce',
          'Chop lettuce',
          'Add dressing',
          'Add croutons',
          'Add cheese',
          'Toss and serve',
        ]),
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: '3',
        name: 'Spaghetti Carbonara',
        typeId: 3,
        typeName: 'Dinner',
        imgPath: null, // User can add image later
        ingredients: Recipe.joinList([
          '400g spaghetti',
          '200g bacon',
          '4 eggs',
          '100g parmesan',
          'Black pepper',
          'Salt',
        ]),
        steps: Recipe.joinList([
          'Cook pasta',
          'Fry bacon',
          'Beat eggs with cheese',
          'Drain pasta',
          'Mix pasta with bacon',
          'Add egg mixture off heat',
          'Add pasta water if needed',
          'Serve with pepper',
        ]),
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: '4',
        name: 'Chocolate Cookies',
        typeId: 4,
        typeName: 'Dessert',
        imgPath: await _copyAssetToLocal(
          'assets/images/recipes/chocolate_cookies.png',
          imagesDir,
          'chocolate_cookies.png',
        ),
        ingredients: Recipe.joinList([
          '2 cups flour',
          '1 tsp baking soda',
          '1 cup butter',
          '3/4 cup sugar',
          '3/4 cup brown sugar',
          '2 eggs',
          '2 tsp vanilla',
          '2 cups chocolate chips',
        ]),
        steps: Recipe.joinList([
          'Preheat oven to 375F',
          'Mix flour and baking soda',
          'Cream butter and sugars',
          'Add eggs and vanilla',
          'Mix in flour',
          'Add chocolate chips',
          'Drop on baking sheet',
          'Bake 9-11 minutes',
        ]),
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: '5',
        name: 'Fruit Smoothie',
        typeId: 6,
        typeName: 'Beverage',
        imgPath: await _copyAssetToLocal(
          'assets/images/recipes/fruit_smoothie.png',
          imagesDir,
          'fruit_smoothie.png',
        ),
        ingredients: Recipe.joinList([
          '1 banana',
          '1 cup strawberries',
          '1/2 cup blueberries',
          '1 cup yogurt',
          '1/2 cup orange juice',
          '1 tbsp honey',
        ]),
        steps: Recipe.joinList([
          'Add fruits to blender',
          'Add yogurt and juice',
          'Add honey',
          'Blend until smooth',
          'Serve immediately',
        ]),
        createdAt: DateTime.now(),
      ),
    ];

    for (var r in samples) {
      await addRecipe(r);
    }
  }

  // Migration method to add images to existing recipes
  static Future<void> _migrateExistingRecipes() async {
    try {
      var appDir = await getDatabasesPath();
      var imagesDir = join(appDir, 'recipe_images');

      // Create images directory if it doesn't exist
      var dir = Directory(imagesDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Update recipe 4 (Chocolate Cookies)
      var recipe4 = await getById('4');
      if (recipe4 != null &&
          (recipe4.imgPath == null || recipe4.imgPath!.isEmpty)) {
        var imgPath = await _copyAssetToLocal(
          'assets/images/recipes/chocolate_cookies.png',
          imagesDir,
          'chocolate_cookies.png',
        );
        if (imgPath != null) {
          recipe4.imgPath = imgPath;
          await update(recipe4);
        }
      }

      // Update recipe 5 (Fruit Smoothie)
      var recipe5 = await getById('5');
      if (recipe5 != null &&
          (recipe5.imgPath == null || recipe5.imgPath!.isEmpty)) {
        var imgPath = await _copyAssetToLocal(
          'assets/images/recipes/fruit_smoothie.png',
          imagesDir,
          'fruit_smoothie.png',
        );
        if (imgPath != null) {
          recipe5.imgPath = imgPath;
          await update(recipe5);
        }
      }
    } catch (e) {
      // Silently fail if migration has issues
      print('Migration error: $e');
    }
  }

  // Helper method to copy asset image to local directory
  static Future<String?> _copyAssetToLocal(
    String assetPath,
    String targetDir,
    String filename,
  ) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();

      final String path = join(targetDir, filename);
      final File file = File(path);
      await file.writeAsBytes(bytes);

      return path;
    } catch (e) {
      // If asset doesn't exist, return null
      return null;
    }
  }
}
