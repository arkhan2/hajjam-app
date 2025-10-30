import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      return AuthResult.failure('Something went wrongqq. Please try again.');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Sign in with Google (web + mobile/desktop)
  Future<AuthResult> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _firebaseAuth.signInWithPopup(provider);
      } else {
        try {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            return AuthResult.failure('Sign-in aborted');
          }
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          userCredential =
              await _firebaseAuth.signInWithCredential(credential);
        } on Exception {
          // Fallback for desktop platforms where google_sign_in may not be supported
          userCredential =
              await _firebaseAuth.signInWithProvider(GoogleAuthProvider());
        }
      }

      final firebaseUser = userCredential.user ?? _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return AuthResult.failure('Failed to sign in.');
      }

      final usersRef = _firestore.collection('users').doc(firebaseUser.uid);
      final now = DateTime.now();
      final existing = await usersRef.get();
      final existingData = existing.data() ?? <String, dynamic>{};
      final userType = (existingData['userType'] as String?) ?? 'user';
      final createdAt = existing.exists
          ? (existingData['createdAt'] as String?) ?? now.toIso8601String()
          : now.toIso8601String();
      final resolvedName = (firebaseUser.displayName?.trim().isNotEmpty == true)
          ? firebaseUser.displayName
          : (firebaseUser.email != null
              ? firebaseUser.email!.split('@').first
              : 'User');

      final update = <String, dynamic>{
        // Required fields
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'displayName': resolvedName,
        'photoURL': firebaseUser.photoURL,
        'userType': userType,
        'createdAt': createdAt,
        'lastLoginAt': now.toIso8601String(),
        // Back-compat with existing model
        'name': resolvedName,
        'profileImageUrl': firebaseUser.photoURL,
      };

      await usersRef.set(update, SetOptions(merge: true));

      final user = await currentUser; // reads mapped app_user.User from Firestore
      if (user == null) {
        return AuthResult.failure('User profile missing.');
      }
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e, s) {
      debugPrint('Google sign-in error: ${e.message}\n$s');
      return AuthResult.failure(e.message ?? 'Google sign-in failed.');
    } catch (e, s) {
      debugPrint('Google sign-in failed: $e\n$s');
      return AuthResult.failure('Unable to sign in with Google.');
    }
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
