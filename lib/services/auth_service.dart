import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';
import 'recipe_service.dart';

class AuthService {
  static const String _keyUserId = 'userId';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  // Initialize users table
  static Future<void> initUsersTable() async {
    final db = RecipeService.db;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        salt TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Create default admin user if no users exist
    var users = await db.query('users');
    if (users.isEmpty) {
      await createDefaultUser();
    }
  }

  // Create default admin user
  static Future<void> createDefaultUser() async {
    final db = RecipeService.db;
    String salt = User.generateSalt();
    String passwordHash = User.hashPassword('admin123', salt);

    User admin = User(
      id: '1',
      username: 'admin',
      passwordHash: passwordHash,
      salt: salt,
      createdAt: DateTime.now(),
    );

    await db.insert('users', admin.toMap());
  }

  // Register new user
  static Future<User?> register(String username, String password) async {
    try {
      final db = RecipeService.db;

      // Check if username exists
      var existing = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (existing.isNotEmpty) {
        return null; // Username taken
      }

      String salt = User.generateSalt();
      String passwordHash = User.hashPassword(password, salt);
      String id = DateTime.now().millisecondsSinceEpoch.toString();

      User newUser = User(
        id: id,
        username: username,
        passwordHash: passwordHash,
        salt: salt,
        createdAt: DateTime.now(),
      );

      await db.insert('users', newUser.toMap());
      return newUser;
    } catch (e) {
      return null;
    }
  }

  // Login
  static Future<User?> login(String username, String password) async {
    try {
      final db = RecipeService.db;

      var result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );

      if (result.isEmpty) {
        return null; // User not found
      }

      User user = User.fromMap(result.first);

      if (user.verifyPassword(password)) {
        // Save session
        await saveSession(user.id);
        return user;
      }

      return null; // Wrong password
    } catch (e) {
      return null;
    }
  }

  // Save session
  static Future<void> saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get current user ID
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
