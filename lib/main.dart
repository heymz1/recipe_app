import 'package:flutter/material.dart';
import 'services/recipe_service.dart';
import 'screens/recipe_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize hive database
  await RecipeService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: RecipeListScreen(),
    );
  }
}
