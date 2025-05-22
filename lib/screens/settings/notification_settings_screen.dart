import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/providers/wallet_provider.dart';
import 'package:wallet_app/themes/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _priceThresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      _priceThresholdController.text =
          walletProvider.priceAlertThreshold.toString();
    });
  }

  @override
  void dispose() {
    _priceThresholdController.dispose();
    super.dispose();
  }

  void _updatePriceThreshold(WalletProvider provider) {
    final text = _priceThresholdController.text;
    if (text.isEmpty) return;

    try {
      final threshold = double.parse(text);
      if (threshold > 0) {
        provider.setPriceAlertThreshold(threshold);
      }
    } catch (_) {
      // Restore the original value
      _priceThresholdController.text = provider.priceAlertThreshold.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction notifications
                _buildSection(
                  title: 'Transaction Notifications',
                  child: _buildToggleSetting(
                    title: 'Enable Transaction Notifications',
                    subtitle:
                        'Get notified when transactions are sent or received',
                    value: provider.notificationsEnabled,
                    onChanged: (value) => provider.toggleNotifications(value),
                  ),
                ),

                const SizedBox(height: 24),

                // Price alert notifications
                _buildSection(
                  title: 'Price Alert Notifications',
                  child: Column(
                    children: [
                      _buildToggleSetting(
                        title: 'Enable Price Alerts',
                        subtitle: 'Get notified of significant price changes',
                        value: provider.priceAlertNotificationsEnabled,
                        onChanged: (value) =>
                            provider.togglePriceAlertNotifications(value),
                      ),
                      if (provider.priceAlertNotificationsEnabled) ...[
                        const SizedBox(height: 16),
                        _buildThresholdSetting(provider),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Demo notification buttons
                _buildSection(
                  title: 'Test Notifications',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Send a test notification to check your settings:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDemoButton(
                              icon: Icons.arrow_downward,
                              label: 'Received',
                              onPressed: () =>
                                  _sendTestReceivedNotification(provider),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDemoButton(
                              icon: Icons.arrow_upward,
                              label: 'Sent',
                              onPressed: () =>
                                  _sendTestSentNotification(provider),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: _buildDemoButton(
                          icon: Icons.show_chart,
                          label: 'Price Alert',
                          onPressed: () => _sendTestPriceNotification(provider),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.secondaryTextColor,
          fontSize: 14,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildThresholdSetting(WalletProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Change Threshold',
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _priceThresholdController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: '%',
              hintText: '5.0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _updatePriceThreshold(provider),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'ll be notified when prices change by this percentage or more',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Future<void> _sendTestReceivedNotification(WalletProvider provider) async {
    if (!provider.notificationsEnabled) {
      _showNotificationDisabledDialog();
      return;
    }

    await provider.addTransaction({
      'from': '0x19E7E376E7C213B7E7e7e46cc70A5dD086DAff2A',
      'to': provider.wallets.isNotEmpty
          ? provider.wallets.first['address']
          : '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
      'value': '0.25',
      'timestamp': DateTime.now().toIso8601String(),
      'hash':
          '0x${DateTime.now().millisecondsSinceEpoch.toString()}abcdef1234567890abcdef',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test received transaction notification sent'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendTestSentNotification(WalletProvider provider) async {
    if (!provider.notificationsEnabled) {
      _showNotificationDisabledDialog();
      return;
    }

    await provider.addTransaction({
      'from': provider.wallets.isNotEmpty
          ? provider.wallets.first['address']
          : '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
      'to': '0x8Ba1f109551bD432803012645Ac136ddd64DBA72',
      'value': '0.15',
      'timestamp': DateTime.now().toIso8601String(),
      'hash':
          '0x${DateTime.now().millisecondsSinceEpoch.toString()}1234567890abcdef1234',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test sent transaction notification sent'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendTestPriceNotification(WalletProvider provider) async {
    if (!provider.priceAlertNotificationsEnabled) {
      _showNotificationDisabledDialog();
      return;
    }

    final cryptoType =
        provider.wallets.isNotEmpty ? provider.wallets.first['type'] : 'ETH';

    await provider.notifyPriceChange(
      cryptoType: cryptoType,
      price: 1250.75,
      changePercent: 8.5,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test price alert notification sent'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showNotificationDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications Disabled'),
        content:
            const Text('Please enable notifications to test this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
