// Simple recipe model for SQLite
class Recipe {
  String id;
  String name;
  int typeId;
  String typeName;
  String? imgPath;
  String ingredients; // stored as comma-separated
  String steps; // stored as comma-separated
  DateTime createdAt;

  Recipe({
    required this.id,
    required this.name,
    required this.typeId,
    required this.typeName,
    this.imgPath,
    required this.ingredients,
    required this.steps,
    required this.createdAt,
  });

  // convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'typeId': typeId,
      'typeName': typeName,
      'imgPath': imgPath,
      'ingredients': ingredients,
      'steps': steps,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // create from database map
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      typeId: map['typeId'],
      typeName: map['typeName'],
      imgPath: map['imgPath'],
      ingredients: map['ingredients'],
      steps: map['steps'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // helper to get ingredients as list
  List<String> getIngredientsList() {
    return ingredients.split('|||').where((s) => s.isNotEmpty).toList();
  }

  // helper to get steps as list
  List<String> getStepsList() {
    return steps.split('|||').where((s) => s.isNotEmpty).toList();
  }

  // helper to create from lists
  static String joinList(List<String> items) {
    return items.join('|||');
  }
}
