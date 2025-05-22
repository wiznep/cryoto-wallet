import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/providers/auth_provider.dart';
import 'package:wallet_app/providers/theme_provider.dart';
import 'package:wallet_app/providers/wallet_provider.dart';
import 'package:wallet_app/providers/biometric_provider.dart';
import 'package:wallet_app/themes/app_theme.dart';
import 'package:wallet_app/utils/number_formatter.dart';
import 'package:wallet_app/widgets/home/action_button.dart';
import 'package:wallet_app/widgets/home/balance_card.dart';
import 'package:wallet_app/widgets/home/wallet_list_item.dart';
import 'package:wallet_app/screens/transaction_detail_screen.dart';
import 'package:wallet_app/screens/receive_screen.dart';
import 'package:wallet_app/screens/send_screen.dart';
import 'package:wallet_app/screens/transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Refresh wallet data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).refreshBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Pages to show based on bottom navigation bar selection
    final List<Widget> pages = [
      _buildWalletPage(walletProvider),
      _buildMarketPage(),
      _buildProfilePage(authProvider, themeProvider),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.secondaryTextColor,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildWalletPage(WalletProvider walletProvider) {
    final selectedWallet = walletProvider.selectedWallet;
    final transactions = walletProvider.transactions;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => walletProvider.refreshBalance(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet Balance',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (selectedWallet != null)
                          Row(
                            children: [
                              Text(
                                '${selectedWallet['type']} ${formatCurrency(selectedWallet['balance'])}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (walletProvider.isLoading)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 16,
                                  height: 16,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Balance Card
                if (selectedWallet != null)
                  BalanceCard(
                    wallet: selectedWallet,
                  ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ActionButton(
                      icon: Icons.arrow_upward,
                      label: 'Send',
                      color: AppTheme.primaryColor,
                      onPressed: () {
                        if (selectedWallet != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SendScreen(
                                wallet: selectedWallet,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No wallet selected'),
                            ),
                          );
                        }
                      },
                    ),
                    ActionButton(
                      icon: Icons.arrow_downward,
                      label: 'Receive',
                      color: AppTheme.secondaryColor,
                      onPressed: () {
                        if (selectedWallet != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReceiveScreen(
                                wallet: selectedWallet,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No wallet selected'),
                            ),
                          );
                        }
                      },
                    ),
                    ActionButton(
                      icon: Icons.swap_horiz,
                      label: 'Swap',
                      color: AppTheme.accentColor,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Swap functionality coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Transactions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (selectedWallet != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransactionHistoryScreen(
                                wallet: selectedWallet,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Transactions List
                if (transactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No transactions yet'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final isReceived = selectedWallet != null &&
                          selectedWallet['address'] == transaction['to'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailScreen(
                                transaction: transaction,
                                walletAddress: selectedWallet?['address'] ?? '',
                                cryptoType: selectedWallet?['type'] ?? 'ETH',
                              ),
                            ),
                          );
                        },
                        child: WalletListItem(
                          title: isReceived ? 'Received' : 'Sent',
                          subtitle: DateTime.parse(transaction['timestamp'])
                              .toString()
                              .substring(0, 16),
                          amount:
                              '${transaction['value']} ${selectedWallet?['type'] ?? 'ETH'}',
                          isPositive: isReceived,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Market Data Coming Soon',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage(
      AuthProvider authProvider, ThemeProvider themeProvider) {
    final user = authProvider.user;
    final biometricProvider = Provider.of<BiometricProvider>(context);
    final isBiometricAvailable = biometricProvider.isBiometricAvailable;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildProfileMenuItem(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeColor: AppTheme.primaryColor,
              ),
              onTap: () => themeProvider.toggleTheme(),
            ),
            const SizedBox(height: 16),
            if (isBiometricAvailable) ...[
              _buildProfileMenuItem(
                icon: Icons.fingerprint,
                title: 'Biometric Authentication',
                trailing: Switch(
                  value: biometricProvider.isBiometricEnabled,
                  onChanged: (value) =>
                      biometricProvider.toggleBiometric(value),
                  activeColor: AppTheme.primaryColor,
                ),
                onTap: () => biometricProvider
                    .toggleBiometric(!biometricProvider.isBiometricEnabled),
              ),
              const SizedBox(height: 16),
            ],
            _buildProfileMenuItem(
              icon: Icons.security,
              title: 'Security',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildProfileMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                await authProvider.signOut();
              },
              textColor: AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? AppTheme.primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
            trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
