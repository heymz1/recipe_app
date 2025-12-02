import 'package:flutter/material.dart';
import 'services/recipe_service.dart';
import 'screens/recipe_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive and load data
  await RecipeService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          elevation: 2,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      ),
      home: const RecipeListScreen(),
    );
  }
}
