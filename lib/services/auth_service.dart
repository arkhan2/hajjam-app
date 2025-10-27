import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _currentUserKey = 'currentUser';
  static const String _usersKey =
      'users'; // Store all users for mock authentication

  late SharedPreferences _prefs;

  // Private constructor
  AuthService._();

  // Singleton instance
  static Future<AuthService> getInstance() async {
    final instance = AuthService._();
    await instance._init();
    return instance;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Check if user is logged in
  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;

  // Get current logged in user
  User? get currentUser {
    final userJson = _prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Error parsing current user: $e');
      return null;
    }
  }

  // Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      // Get all stored users
      final users = await _getAllUsers();

      // Find user with matching email
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      // For mock authentication, we'll just check if password is not empty
      // In a real app, you'd hash and compare passwords
      if (password.isEmpty) {
        return AuthResult.failure('Password is required');
      }

      // Store login state
      await _prefs.setBool(_isLoggedInKey, true);
      await _prefs.setString(_currentUserKey, jsonEncode(user.toJson()));

      print('Login success for user: ${user.name}');
      return AuthResult.success(user);
    } catch (e) {
      print('Login failed: $e');
      return AuthResult.failure('Invalid email or password');
    }
  }

  // Sign up with user details
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? phoneNumber,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return AuthResult.failure('All fields are required');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }

      // Check if user already exists
      final users = await _getAllUsers();
      final existingUser = users.any(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (existingUser) {
        return AuthResult.failure('An account with this email already exists');
      }

      // Create new user
      final newUser = User.create(
        email: email,
        name: name,
        userType: userType,
        phoneNumber: phoneNumber,
      );

      // Save user to storage
      users.add(newUser);
      await _saveAllUsers(users);

      // Store login state
      await _prefs.setBool(_isLoggedInKey, true);
      await _prefs.setString(_currentUserKey, jsonEncode(newUser.toJson()));

      print('Signup success for user: ${newUser.name}');
      return AuthResult.success(newUser);
    } catch (e) {
      print('Signup failed: $e');
      return AuthResult.failure('Failed to create account. Please try again.');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _prefs.remove(_isLoggedInKey);
    await _prefs.remove(_currentUserKey);
    print('User logged out');
  }

  // Get all users (for mock authentication)
  Future<List<User>> _getAllUsers() async {
    final usersJson = _prefs.getStringList(_usersKey);
    if (usersJson == null) return [];

    try {
      return usersJson
          .map((jsonString) => User.fromJson(jsonDecode(jsonString)))
          .toList();
    } catch (e) {
      print('Error parsing users: $e');
      return [];
    }
  }

  // Save all users (for mock authentication)
  Future<void> _saveAllUsers(List<User> users) async {
    final usersJson = users.map((user) => jsonEncode(user.toJson())).toList();
    await _prefs.setStringList(_usersKey, usersJson);
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Update current user profile
  Future<AuthResult> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final currentUser = this.currentUser;
      if (currentUser == null) {
        return AuthResult.failure('No user logged in');
      }

      final updatedUser = currentUser.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );

      // Update in storage
      await _prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));

      // Update in users list
      final users = await _getAllUsers();
      final userIndex = users.indexWhere((u) => u.id == currentUser.id);
      if (userIndex != -1) {
        users[userIndex] = updatedUser;
        await _saveAllUsers(users);
      }

      print('Profile updated for user: ${updatedUser.name}');
      return AuthResult.success(updatedUser);
    } catch (e) {
      print('Profile update failed: $e');
      return AuthResult.failure('Failed to update profile');
    }
  }

  // Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    await _prefs.clear();
    print('All authentication data cleared');
  }
}

// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(User user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(isSuccess: false, errorMessage: errorMessage);
  }
}
