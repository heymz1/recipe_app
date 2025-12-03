import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../models/recipe_type_model.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';
import '../widgets/recipe_card_widget.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';
import 'login_screen.dart';

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  List<Recipe> recipes = [];
  List<RecipeType> types = [];
  RecipeType? selectedType;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() => loading = true);

    var recipeTypes = await RecipeService.getTypes();
    var allRecipes = await RecipeService.getAll(); // now async

    setState(() {
      types = recipeTypes;
      recipes = allRecipes;
      loading = false;
    });
  }

  Future<List<Recipe>> getFilteredRecipes() async {
    if (selectedType == null) {
      return await RecipeService.getAll();
    }
    return await RecipeService.filterByType(selectedType!.id);
  }

  void goToDetail(Recipe r) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: r)),
    );
    if (result == true) {
      loadData();
    }
  }

  void goToAdd() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipeFormScreen(types: types)),
    );
    if (result == true) {
      loadData();
    }
  }

  Future<void> handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipes'),
        backgroundColor: Colors.orange[100],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: handleLogout,
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // filter dropdown
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<RecipeType>(
                          value: selectedType,
                          decoration: InputDecoration(
                            labelText: 'Filter by Type',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: null, child: Text('All')),
                            ...types.map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.name),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() => selectedType = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // recipe grid
                Expanded(
                  child: FutureBuilder<List<Recipe>>(
                    future: getFilteredRecipes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var filtered = snapshot.data!;

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text('No recipes found'),
                            ],
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          int cols = 2;
                          if (constraints.maxWidth > 900) {
                            cols = 4;
                          } else if (constraints.maxWidth > 600) {
                            cols = 3;
                          }

                          return GridView.builder(
                            padding: EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return RecipeCard(
                                recipe: filtered[index],
                                onTap: () => goToDetail(filtered[index]),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToAdd,
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
