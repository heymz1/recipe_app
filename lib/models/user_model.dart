import 'dart:convert';
import 'package:crypto/crypto.dart';

class User {
  String id;
  String username;
  String passwordHash;
  String salt;
  DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  // Convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'salt': salt,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from database map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      passwordHash: map['passwordHash'],
      salt: map['salt'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Hash password with salt
  static String hashPassword(String password, String salt) {
    var bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  // Verify password
  bool verifyPassword(String password) {
    return hashPassword(password, salt) == passwordHash;
  }

  // Generate random salt
  static String generateSalt() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
