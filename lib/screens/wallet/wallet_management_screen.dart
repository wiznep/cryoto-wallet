import 'package:flutter/material.dart';
import 'package:wallet_app/screens/wallet/create_wallet_screen.dart';
import 'package:wallet_app/screens/wallet/import_wallet_screen.dart';
import 'package:wallet_app/themes/app_theme.dart';

class WalletManagementScreen extends StatelessWidget {
  const WalletManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Management'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const SizedBox(height: 20),
            const Center(
              child: Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Manage Your Wallets',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create a new wallet or import an existing one',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Create Wallet Option
            _buildOptionCard(
              context,
              icon: Icons.add_circle_outline,
              title: 'Create New Wallet',
              description:
                  'Generate a new wallet with a unique seed phrase for secure storage of your assets',
              buttonText: 'Create Wallet',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateWalletScreen()),
                );
              },
              primary: true,
            ),

            const SizedBox(height: 24),

            // Import Wallet Option
            _buildOptionCard(
              context,
              icon: Icons.file_download_outlined,
              title: 'Import Existing Wallet',
              description: 'Restore your wallet using a seed phrase',
              buttonText: 'Import Wallet',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ImportWalletScreen()),
                );
              },
              primary: false,
            ),

            const Spacer(),

            Text(
              'Note: Securely store your seed phrase in a safe place. It\'s your responsibility to keep it secure. If lost, your assets can\'t be recovered.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
    required bool primary,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primary
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              primary ? AppTheme.primaryColor : Theme.of(context).dividerColor,
          width: primary ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 40,
            color: primary ? AppTheme.primaryColor : AppTheme.secondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    primary ? AppTheme.primaryColor : Colors.transparent,
                foregroundColor: primary ? Colors.white : AppTheme.primaryColor,
                elevation: primary ? 0 : 0,
                side: primary ? null : BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
