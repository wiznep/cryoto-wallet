import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class User {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  User({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });
}

class AuthProvider extends ChangeNotifier {
  User? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get userRole => 'user'; // Simplified for demo

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        // Mock user data
        _user = User(
          uid: '123456',
          email: prefs.getString('userEmail'),
          displayName: prefs.getString('userName') ?? 'User',
          photoURL: null,
        );
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Failed to initialize: $e';
    }

    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Simple validation for demo
      if (email.isEmpty || !email.contains('@')) {
        _status = AuthStatus.error;
        _errorMessage = 'Invalid email format';
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _status = AuthStatus.error;
        _errorMessage = 'Password must be at least 6 characters';
        notifyListeners();
        return false;
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Demo authentication - in real app, would call Firebase Auth
      _user = User(
        uid: '123456',
        email: email,
        displayName: email.split('@').first,
        photoURL: null,
      );

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', email.split('@').first);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(
      String email, String password, String name) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Simple validation for demo
      if (email.isEmpty || !email.contains('@')) {
        _status = AuthStatus.error;
        _errorMessage = 'Invalid email format';
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _status = AuthStatus.error;
        _errorMessage = 'Password must be at least 6 characters';
        notifyListeners();
        return false;
      }

      if (name.isEmpty) {
        _status = AuthStatus.error;
        _errorMessage = 'Name is required';
        notifyListeners();
        return false;
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Demo registration - in real app, would call Firebase Auth
      _user = User(
        uid: '123456',
        email: email,
        displayName: name,
        photoURL: null,
      );

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', name);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Demo Google sign-in - in real app, would call Firebase Auth with Google provider
      _user = User(
        uid: '789012',
        email: 'demo.user@gmail.com',
        displayName: 'Demo User',
        photoURL: null,
      );

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', 'demo.user@gmail.com');
      await prefs.setString('userName', 'Demo User');

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Google sign in failed: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Sign out failed: $e';
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Simple validation for demo
      if (email.isEmpty || !email.contains('@')) {
        _status = AuthStatus.error;
        _errorMessage = 'Invalid email format';
        notifyListeners();
        return false;
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Demo password reset - in real app, would call Firebase Auth
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Password reset failed: $e';
      notifyListeners();
      return false;
    }
  }
}
