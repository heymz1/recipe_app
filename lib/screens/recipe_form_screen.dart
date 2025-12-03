import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recipe_model.dart';
import '../models/recipe_type_model.dart';
import '../services/recipe_service.dart';

class RecipeFormScreen extends StatefulWidget {
  final List<RecipeType> types;
  final Recipe? recipe;

  RecipeFormScreen({required this.types, this.recipe});

  @override
  _RecipeFormScreenState createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  RecipeType? selectedType;
  String? imagePath;
  List<TextEditingController> ingredientControllers = [];
  List<TextEditingController> stepControllers = [];
  bool saving = false;

  @override
  void initState() {
    super.initState();

    if (widget.recipe != null) {
      // editing mode
      nameController.text = widget.recipe!.name;
      selectedType = widget.types.firstWhere(
        (t) => t.id == widget.recipe!.typeId,
      );
      imagePath = widget.recipe!.imgPath;

      // load ingredients from string
      var ings = widget.recipe!.getIngredientsList();
      for (var ing in ings) {
        ingredientControllers.add(TextEditingController(text: ing));
      }

      // load steps from string
      var stps = widget.recipe!.getStepsList();
      for (var step in stps) {
        stepControllers.add(TextEditingController(text: step));
      }
    } else {
      // new recipe
      addIngredient();
      addStep();
    }
  }

  void addIngredient() {
    setState(() {
      ingredientControllers.add(TextEditingController());
    });
  }

  void removeIngredient(int index) {
    if (ingredientControllers.length > 1) {
      setState(() {
        ingredientControllers[index].dispose();
        ingredientControllers.removeAt(index);
      });
    }
  }

  void addStep() {
    setState(() {
      stepControllers.add(TextEditingController());
    });
  }

  void removeStep(int index) {
    if (stepControllers.length > 1) {
      setState(() {
        stepControllers[index].dispose();
        stepControllers.removeAt(index);
      });
    }
  }

  void pickImage() async {
    final picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      var dir = await getApplicationDocumentsDirectory();
      var filename = 'recipe_${DateTime.now().millisecondsSinceEpoch}.jpg';
      var savedPath = '${dir.path}/$filename';
      await File(image.path).copy(savedPath);

      setState(() => imagePath = savedPath);
    }
  }

  void saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select recipe type')));
      return;
    }

    var ingredients = ingredientControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    var steps = stepControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Add at least one ingredient')));
      return;
    }

    if (steps.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Add at least one step')));
      return;
    }

    setState(() => saving = true);

    var recipe = Recipe(
      id: widget.recipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      typeId: selectedType!.id,
      typeName: selectedType!.name,
      imgPath: imagePath,
      ingredients: Recipe.joinList(ingredients),
      steps: Recipe.joinList(steps),
      createdAt: widget.recipe?.createdAt ?? DateTime.now(),
    );

    if (widget.recipe != null) {
      await RecipeService.update(recipe);
    } else {
      await RecipeService.addRecipe(recipe);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.recipe != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Recipe' : 'New Recipe'),
        backgroundColor: Colors.orange[100],
      ),
      body: saving
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Recipe Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  ),

                  SizedBox(height: 15),

                  DropdownButtonFormField<RecipeType>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: widget.types
                        .map(
                          (t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedType = val),
                  ),

                  SizedBox(height: 20),

                  Text(
                    'Image',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  if (imagePath != null)
                    Stack(
                      children: [
                        Image.file(
                          File(imagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                            onPressed: () => setState(() => imagePath = null),
                          ),
                        ),
                      ],
                    ),

                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: Icon(Icons.photo),
                    label: Text(
                      imagePath != null ? 'Change Image' : 'Add Image',
                    ),
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.orange),
                        onPressed: addIngredient,
                      ),
                    ],
                  ),

                  ...ingredientControllers.asMap().entries.map(
                    (e) => Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: e.value,
                              decoration: InputDecoration(
                                labelText: 'Ingredient ${e.key + 1}',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          if (ingredientControllers.length > 1)
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () => removeIngredient(e.key),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Steps',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.orange),
                        onPressed: addStep,
                      ),
                    ],
                  ),

                  ...stepControllers.asMap().entries.map(
                    (e) => Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: e.value,
                              decoration: InputDecoration(
                                labelText: 'Step ${e.key + 1}',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                          ),
                          if (stepControllers.length > 1)
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () => removeStep(e.key),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: saveRecipe,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(15),
                      backgroundColor: Colors.orange,
                    ),
                    child: Text(
                      isEdit ? 'Update' : 'Save',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
