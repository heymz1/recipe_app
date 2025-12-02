import 'package:hive/hive.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int recipeTypeId;

  @HiveField(3)
  String recipeTypeName;

  @HiveField(4)
  String? imagePath;

  @HiveField(5)
  List<String> ingredients;

  @HiveField(6)
  List<String> steps;

  @HiveField(7)
  DateTime createdAt;

  Recipe({
    required this.id,
    required this.name,
    required this.recipeTypeId,
    required this.recipeTypeName,
    this.imagePath,
    required this.ingredients,
    required this.steps,
    required this.createdAt,
  });

  // Copy with method for easier editing
  Recipe copyWith({
    String? id,
    String? name,
    int? recipeTypeId,
    String? recipeTypeName,
    String? imagePath,
    List<String>? ingredients,
    List<String>? steps,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      recipeTypeId: recipeTypeId ?? this.recipeTypeId,
      recipeTypeName: recipeTypeName ?? this.recipeTypeName,
      imagePath: imagePath ?? this.imagePath,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
