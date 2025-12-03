import 'dart:convert';

// Simple model for recipe type
class RecipeType {
  int id;
  String name;

  RecipeType({required this.id, required this.name});

  // from json
  factory RecipeType.fromJson(Map<String, dynamic> json) {
    return RecipeType(id: json['id'], name: json['name']);
  }

  // parse the json file
  static List<RecipeType> parseJson(String jsonStr) {
    var data = json.decode(jsonStr);
    List types = data['recipeTypes'];
    return types.map((t) => RecipeType.fromJson(t)).toList();
  }

  @override
  String toString() => name;
}
