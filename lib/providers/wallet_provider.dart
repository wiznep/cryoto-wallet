import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wallet_app/services/notification_service.dart';

class WalletProvider extends ChangeNotifier {
  final _walletBox = Hive.box('walletBox');
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  List<Map<String, dynamic>> _wallets = [];
  Map<String, dynamic>? _selectedWallet;
  List<Map<String, dynamic>> _transactions = [];

  // Notification settings
  bool _notificationsEnabled = true;
  bool _priceAlertNotificationsEnabled = true;
  double _priceAlertThreshold = 5.0; // 5% price change

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get wallets => _wallets;
  Map<String, dynamic>? get selectedWallet => _selectedWallet;
  List<Map<String, dynamic>> get transactions => _transactions;

  // Notification settings getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get priceAlertNotificationsEnabled => _priceAlertNotificationsEnabled;
  double get priceAlertThreshold => _priceAlertThreshold;

  WalletProvider() {
    _loadWallets();
    _loadTransactions();
  }

  void _loadWallets() {
    try {
      final storedWallets = _walletBox.get('wallets');
      if (storedWallets != null) {
        _wallets = (storedWallets as List).map<Map<String, dynamic>>((item) {
          return Map<String, dynamic>.from(item as Map);
        }).toList();

        // Set the first wallet as selected if available
        if (_wallets.isNotEmpty) {
          _selectedWallet = _wallets.first;
        }
      } else {
        // Create a demo wallet if none exists
        _createDemoWallet();
      }
    } catch (e) {
      debugPrint('Error loading wallets: $e');
      _createDemoWallet();
    }
    notifyListeners();
  }

  void _createDemoWallet() {
    final demoWallet = {
      'name': 'Main Wallet',
      'address': '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
      'balance': '2.45',
      'type': 'ETH',
    };

    _wallets = [demoWallet];
    _selectedWallet = demoWallet;
    _walletBox.put('wallets', _wallets);
  }

  void _loadTransactions() {
    try {
      final storedTransactions = _walletBox.get('transactions');
      if (storedTransactions != null) {
        _transactions =
            (storedTransactions as List).map<Map<String, dynamic>>((item) {
          return Map<String, dynamic>.from(item as Map);
        }).toList();
      } else {
        // Create demo transactions if none exist
        _createDemoTransactions();
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      _createDemoTransactions();
    }
    notifyListeners();
  }

  void _createDemoTransactions() {
    if (_wallets.isEmpty) return;

    final walletAddress = _wallets.first['address'];
    final demoTransactions = [
      {
        'from': '0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0',
        'to': walletAddress,
        'value': '0.5',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'hash':
            '0x3a1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e',
      },
      {
        'from': walletAddress,
        'to': '0xc5be1e5ebec7d5bd14f71427d1e84f3dd0314c0',
        'value': '0.1',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'hash':
            '0x4a1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e',
      },
      {
        'from': '0x71be1e5ebec7d5bd14f71427d1e84f3dd0314c0',
        'to': walletAddress,
        'value': '1.2',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'hash':
            '0x5a1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e1b1e',
      },
    ];

    _transactions = demoTransactions;
    _walletBox.put('transactions', _transactions);
  }

  Future<void> refreshBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, fetch balances from blockchain
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, randomly update balance
      if (_selectedWallet != null) {
        final double currentBalance =
            double.parse(_selectedWallet!['balance'] as String);
        final double change = (currentBalance * 0.01); // 1% change for demo
        final double newBalance = (currentBalance + change);
        _selectedWallet!['balance'] = newBalance.toStringAsFixed(2);
      }
    } catch (e) {
      debugPrint('Error refreshing balance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectWallet(String address) {
    final wallet = _wallets.firstWhere(
      (wallet) => wallet['address'] == address,
      orElse: () => _wallets.first,
    );

    _selectedWallet = wallet;
    notifyListeners();
  }

  Future<void> addWallet(String name, String address) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final newWallet = {
      'name': name,
      'address': address,
      'balance': '0.0',
      'type': 'ETH',
    };

    _wallets.add(newWallet);
    _walletBox.put('wallets', _wallets);

    _isLoading = false;
    notifyListeners();
  }

  // Toggle transaction notifications
  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  // Toggle price alert notifications
  void togglePriceAlertNotifications(bool enabled) {
    _priceAlertNotificationsEnabled = enabled;
    notifyListeners();
  }

  // Set price alert threshold
  void setPriceAlertThreshold(double threshold) {
    _priceAlertThreshold = threshold;
    notifyListeners();
  }

  // Add a transaction
  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    _transactions.add(transaction);

    // Show transaction notification if enabled
    if (_notificationsEnabled) {
      final String walletAddress = transaction['from'];
      final String recipientAddress = transaction['to'];
      final String amount = transaction['value'];
      final String cryptoType =
          _getCryptoTypeForAddress(walletAddress) ?? 'ETH';
      final String transactionId = transaction['hash'];

      // Check if this is a received or sent transaction
      final isSent = _isOwnWalletAddress(walletAddress);
      final isReceived = _isOwnWalletAddress(recipientAddress);

      if (isSent) {
        // This is a sent transaction
        await _notificationService.showSentTransactionNotification(
          cryptoType: cryptoType,
          amount: amount,
          to: _formatAddress(recipientAddress),
          transactionId: transactionId,
        );
      } else if (isReceived) {
        // This is a received transaction
        await _notificationService.showReceivedTransactionNotification(
          cryptoType: cryptoType,
          amount: amount,
          from: _formatAddress(walletAddress),
          transactionId: transactionId,
        );
      }
    }

    notifyListeners();
  }

  // Check if an address belongs to one of our wallets
  bool _isOwnWalletAddress(String address) {
    return _wallets.any((wallet) => wallet['address'] == address);
  }

  // Get the crypto type for a wallet address
  String? _getCryptoTypeForAddress(String address) {
    final wallet = _wallets.firstWhere(
      (wallet) => wallet['address'] == address,
      orElse: () => {'type': null},
    );
    return wallet['type'];
  }

  // Format address for display in notifications
  String _formatAddress(String address) {
    if (address.length <= 15) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  // Notify about price changes (simulate price alerts)
  Future<void> notifyPriceChange({
    required String cryptoType,
    required double price,
    required double changePercent,
  }) async {
    // Only show price alert notifications if enabled and change is above threshold
    if (_priceAlertNotificationsEnabled &&
        changePercent.abs() >= _priceAlertThreshold) {
      await _notificationService.showPriceAlertNotification(
        cryptoType: cryptoType,
        price: price,
        changePercent: changePercent,
      );
    }
  }
}
