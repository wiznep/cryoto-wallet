import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wallet_app/providers/theme_provider.dart';
import 'package:wallet_app/providers/auth_provider.dart';
import 'package:wallet_app/providers/wallet_provider.dart';
import 'package:wallet_app/providers/biometric_provider.dart';
import 'package:wallet_app/providers/price_provider.dart';
import 'package:wallet_app/screens/splash_screen.dart';
import 'package:wallet_app/themes/app_theme.dart';
import 'package:wallet_app/services/notification_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('walletBox');

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set up providers for state management
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(
            create: (_) => BiometricProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => PriceProvider()),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);

          // Initialize wallet provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final walletProvider =
                Provider.of<WalletProvider>(context, listen: false);
            walletProvider.refreshBalance();
          });

          return MaterialApp(
            title: 'Wallet App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
