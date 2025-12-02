import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recipe_model.dart';
import '../models/recipe_type_model.dart';
import '../services/recipe_service.dart';

class RecipeFormScreen extends StatefulWidget {
  final List<RecipeType> recipeTypes;
  final Recipe? recipe; // null for creating new recipe

  const RecipeFormScreen({
    super.key,
    required this.recipeTypes,
    this.recipe,
  });

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  RecipeType? _selectedType;
  String? _imagePath;
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _stepControllers = [];
  
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    if (widget.recipe != null) {
      // Editing existing recipe
      _nameController.text = widget.recipe!.name;
      _selectedType = widget.recipeTypes.firstWhere(
        (type) => type.id == widget.recipe!.recipeTypeId,
        orElse: () => widget.recipeTypes.first,
      );
      _imagePath = widget.recipe!.imagePath;
      
      // Load ingredients
      for (final ingredient in widget.recipe!.ingredients) {
        final controller = TextEditingController(text: ingredient);
        _ingredientControllers.add(controller);
      }
      
      // Load steps
      for (final step in widget.recipe!.steps) {
        final controller = TextEditingController(text: step);
        _stepControllers.add(controller);
      }
    } else {
      // Creating new recipe - add one empty field for each
      _addIngredientField();
      _addStepField();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _ingredientControllers) {
      controller.dispose();
    }
    for (final controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStepField(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Save image to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${appDir.path}/$fileName');
        await image.saveTo(savedImage.path);
        
        setState(() {
          _imagePath = savedImage.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipe type')),
      );
      return;
    }
    
    // Get non-empty ingredients and steps
    final ingredients = _ingredientControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    final steps = _stepControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }
    
    if (steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one step')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final recipe = Recipe(
        id: widget.recipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        recipeTypeId: _selectedType!.id,
        recipeTypeName: _selectedType!.name,
        imagePath: _imagePath,
        ingredients: ingredients,
        steps: steps,
        createdAt: widget.recipe?.createdAt ?? DateTime.now(),
      );
      
      if (widget.recipe != null) {
        await RecipeService.updateRecipe(recipe);
      } else {
        await RecipeService.createRecipe(recipe);
      }
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving recipe: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recipe' : 'New Recipe'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Recipe Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Name',
                      hintText: 'Enter recipe name',
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a recipe name';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Recipe Type Dropdown
                  DropdownButtonFormField<RecipeType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: widget.recipeTypes.map((type) {
                      return DropdownMenuItem<RecipeType>(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (RecipeType? value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a recipe type';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Image Section
                  Text(
                    'Recipe Image',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_imagePath != null && _imagePath!.isNotEmpty)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _imagePath = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(_imagePath != null ? 'Change Image' : 'Add Image'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Ingredients Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton.filled(
                        onPressed: _addIngredientField,
                        icon: const Icon(Icons.add),
                        tooltip: 'Add Ingredient',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  ..._ingredientControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              decoration: InputDecoration(
                                labelText: 'Ingredient ${index + 1}',
                                hintText: 'e.g., 2 cups flour',
                                prefixIcon: const Icon(Icons.shopping_basket),
                              ),
                            ),
                          ),
                          if (_ingredientControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () => _removeIngredientField(index),
                            ),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // Steps Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton.filled(
                        onPressed: _addStepField,
                        icon: const Icon(Icons.add),
                        tooltip: 'Add Step',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  ..._stepControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              decoration: InputDecoration(
                                labelText: 'Step ${index + 1}',
                                hintText: 'Describe this step',
                                prefixIcon: const Icon(Icons.format_list_numbered),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                              minLines: 1,
                            ),
                          ),
                          if (_stepControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () => _removeStepField(index),
                            ),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  FilledButton.icon(
                    onPressed: _saveRecipe,
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? 'Update Recipe' : 'Save Recipe'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
