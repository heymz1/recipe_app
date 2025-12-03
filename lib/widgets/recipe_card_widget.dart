import 'dart:io';
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final Function() onTap;

  RecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image part
            AspectRatio(
              aspectRatio: 16 / 9,
              child: recipe.imgPath != null && recipe.imgPath!.isNotEmpty
                  ? Image.file(
                      File(recipe.imgPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _placeholder(context);
                      },
                    )
                  : _placeholder(context),
            ),
            // info part
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.restaurant, size: 14, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        recipe.typeName,
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.restaurant_menu, size: 60, color: Colors.grey[600]),
      ),
    );
  }
}
