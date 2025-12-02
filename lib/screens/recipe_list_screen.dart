import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../models/recipe_type_model.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_card_widget.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  List<Recipe> _recipes = [];
  List<RecipeType> _recipeTypes = [];
  RecipeType? _selectedType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final types = await RecipeService.loadRecipeTypes();
      final recipes = RecipeService.getAllRecipes();
      
      setState(() {
        _recipeTypes = types;
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  List<Recipe> _getFilteredRecipes() {
    if (_selectedType == null) {
      return _recipes;
    }
    return RecipeService.getRecipesByType(_selectedType!.id);
  }

  void _navigateToDetail(Recipe recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );
    
    // Refresh list if recipe was modified or deleted
    if (result == true) {
      _loadData();
    }
  }

  void _navigateToAddRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeFormScreen(recipeTypes: _recipeTypes),
      ),
    );
    
    // Refresh list if a new recipe was added
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = _getFilteredRecipes();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<RecipeType>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Type',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          hint: const Text('All Recipes'),
                          items: [
                            const DropdownMenuItem<RecipeType>(
                              value: null,
                              child: Text('All Recipes'),
                            ),
                            ..._recipeTypes.map((type) {
                              return DropdownMenuItem<RecipeType>(
                                value: type,
                                child: Text(type.name),
                              );
                            }),
                          ],
                          onChanged: (RecipeType? newValue) {
                            setState(() {
                              _selectedType = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Recipe Grid
                Expanded(
                  child: filteredRecipes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recipes found',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to add your first recipe',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            // Responsive grid columns
                            int columns = 2;
                            if (constraints.maxWidth > 900) {
                              columns = 4;
                            } else if (constraints.maxWidth > 600) {
                              columns = 3;
                            }
                            
                            return GridView.builder(
                              padding: const EdgeInsets.all(16.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: filteredRecipes.length,
                              itemBuilder: (context, index) {
                                final recipe = filteredRecipes[index];
                                return RecipeCardWidget(
                                  recipe: recipe,
                                  onTap: () => _navigateToDetail(recipe),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddRecipe,
        icon: const Icon(Icons.add),
        label: const Text('Add Recipe'),
      ),
    );
  }
}
