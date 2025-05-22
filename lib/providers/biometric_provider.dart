import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_app/services/biometric_service.dart';
import 'package:local_auth/local_auth.dart';

class BiometricProvider extends ChangeNotifier {
  final BiometricService _biometricService = BiometricService();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  List<BiometricType> _availableBiometrics = [];

  // Getters
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isBiometricEnabled => _isBiometricEnabled;
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  // Initialize biometric settings
  Future<void> initialize() async {
    _isBiometricAvailable = await _biometricService.isBiometricAvailable();

    if (_isBiometricAvailable) {
      _availableBiometrics = await _biometricService.getAvailableBiometrics();

      // Load saved preference
      final prefs = await SharedPreferences.getInstance();
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    }

    notifyListeners();
  }

  // Toggle biometric authentication on/off
  Future<void> toggleBiometric(bool value) async {
    if (!_isBiometricAvailable) return;

    // If enabling biometrics, first verify user can authenticate
    if (value && !_isBiometricEnabled) {
      final authenticated = await _biometricService.authenticateWithBiometrics(
        reason: 'Verify your identity to enable biometric authentication',
      );

      if (!authenticated) return; // Authentication failed
    }

    // Save the preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);

    _isBiometricEnabled = value;
    notifyListeners();
  }

  // Authenticate using biometrics
  Future<bool> authenticate({String? reason}) async {
    if (!_isBiometricAvailable || !_isBiometricEnabled) return true;

    return await _biometricService.authenticateWithBiometrics(
      reason: reason ?? 'Verify your identity to access your wallet',
    );
  }
}
