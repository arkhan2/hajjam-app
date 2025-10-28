import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart' as app_user;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user from Firestore
  Future<app_user.User?> get currentUser async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      return app_user.User.fromJson(userDoc.data()!);
    }
    return null;
  }

  // Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    required String userType, // 'user' or 'barber'
    String? phoneNumber,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return AuthResult.failure('Failed to create user.');
      }

      // Create user profile in Firestore
      final user = app_user.User(
        id: firebaseUser.uid,
        email: email,
        name: name,
        userType: userType,
        createdAt: DateTime.now(),
        phoneNumber: phoneNumber,
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(user.toJson());

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('Signup error: ${e.message}');
      return AuthResult.failure(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      debugPrint('Signup failed: $e');
      return AuthResult.failure('Failed to create account. Please try again.');
    }
  }

  // Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final user = await currentUser;
      if (user == null) {
        return AuthResult.failure('User not found in Firestore.');
      }
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.message}');
      return AuthResult.failure(e.message ?? 'Invalid email or password');
    } catch (e) {
      debugPrint('Login failed: $e');
      return AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}

// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final app_user.User? user;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(app_user.User user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(isSuccess: false, errorMessage: errorMessage);
  }
}
