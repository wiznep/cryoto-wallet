import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wallet_app/providers/biometric_provider.dart';
import 'package:wallet_app/screens/home_screen.dart';
import 'package:wallet_app/themes/app_theme.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  bool _isAuthenticating = true;
  bool _authFailed = false;

  @override
  void initState() {
    super.initState();
    _authenticateWithBiometrics();
  }

  Future<void> _authenticateWithBiometrics() async {
    final biometricProvider =
        Provider.of<BiometricProvider>(context, listen: false);

    setState(() {
      _isAuthenticating = true;
      _authFailed = false;
    });

    final authenticated = await biometricProvider.authenticate();

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
        _authFailed = !authenticated;
      });

      if (authenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometricProvider = Provider.of<BiometricProvider>(context);
    final availableBiometrics = biometricProvider.availableBiometrics;
    final bool hasFaceId = availableBiometrics.contains(BiometricType.face);
    final bool hasFingerprint =
        availableBiometrics.contains(BiometricType.fingerprint);

    String biometricType = 'Biometric';
    if (hasFaceId)
      biometricType = 'Face ID';
    else if (hasFingerprint) biometricType = 'Fingerprint';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: AppTheme.primaryColor,
              ),

              const SizedBox(height: 48),

              Text(
                'Wallet App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Secure Your Assets',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.secondaryTextColor,
                ),
              ),

              const SizedBox(height: 64),

              // Biometric Authentication UI
              Icon(
                hasFaceId
                    ? Icons.face
                    : hasFingerprint
                        ? Icons.fingerprint
                        : Icons.security,
                size: 70,
                color:
                    _authFailed ? AppTheme.errorColor : AppTheme.primaryColor,
              ),

              const SizedBox(height: 24),

              Text(
                _authFailed
                    ? 'Authentication Failed'
                    : 'Use $biometricType to unlock',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _authFailed ? AppTheme.errorColor : null,
                ),
              ),

              const SizedBox(height: 32),

              if (_authFailed)
                ElevatedButton(
                  onPressed: _authenticateWithBiometrics,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
