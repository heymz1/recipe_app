import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe recipe;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
  }

  void editRecipe() async {
    var types = await RecipeService.getTypes();

    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeFormScreen(types: types, recipe: recipe),
      ),
    );

    if (result == true) {
      // reload recipe
      var updated = await RecipeService.getById(recipe.id);
      if (updated != null) {
        setState(() => recipe = updated);
      }
    }
  }

  void deleteRecipe() async {
    var confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Recipe'),
        content: Text('Delete "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await RecipeService.delete(recipe.id);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    var ingredients = recipe.getIngredientsList();
    var steps = recipe.getStepsList();

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        backgroundColor: Colors.orange[100],
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: editRecipe),
          IconButton(icon: Icon(Icons.delete), onPressed: deleteRecipe),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image
            if (recipe.imgPath != null && recipe.imgPath!.isNotEmpty)
              Image.file(
                File(recipe.imgPath!),
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 250,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // type badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      recipe.typeName,
                      style: TextStyle(color: Colors.orange[900]),
                    ),
                  ),

                  SizedBox(height: 20),

                  // ingredients
                  Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ...ingredients.map(
                    (ing) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Expanded(child: Text(ing)),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // steps
                  Text(
                    'Instructions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ...steps.asMap().entries.map(
                    (e) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.orange,
                            child: Text(
                              '${e.key + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(child: Text(e.value)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
