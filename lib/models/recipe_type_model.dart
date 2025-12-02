import 'dart:convert';

class RecipeType {
  final int id;
  final String name;

  RecipeType({
    required this.id,
    required this.name,
  });

  factory RecipeType.fromJson(Map<String, dynamic> json) {
    return RecipeType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  static List<RecipeType> listFromJson(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> types = data['recipeTypes'];
    return types.map((json) => RecipeType.fromJson(json)).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeType && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => name;
}
