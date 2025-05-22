import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/providers/price_provider.dart';
import 'package:wallet_app/providers/wallet_provider.dart';
import 'package:wallet_app/themes/app_theme.dart';
import 'package:wallet_app/widgets/price_chart/crypto_price_chart.dart';
import 'package:intl/intl.dart';

class CryptoDetailScreen extends StatefulWidget {
  final Map<String, dynamic> wallet;

  const CryptoDetailScreen({
    super.key,
    required this.wallet,
  });

  @override
  State<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends State<CryptoDetailScreen> {
  late String _cryptoId;
  late String _symbol;

  @override
  void initState() {
    super.initState();

    // Convert wallet type to CoinGecko ID
    _symbol = widget.wallet['type'] ?? 'ETH';
    switch (_symbol.toLowerCase()) {
      case 'eth':
        _cryptoId = 'ethereum';
        break;
      case 'btc':
        _cryptoId = 'bitcoin';
        break;
      case 'bnb':
        _cryptoId = 'binancecoin';
        break;
      case 'sol':
        _cryptoId = 'solana';
        break;
      default:
        _cryptoId = 'ethereum';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceProvider = Provider.of<PriceProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$_symbol Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withAlpha(180),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_symbol Wallet',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        radius: 16,
                        child: Text(
                          _symbol.substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.wallet['balance']} $_symbol',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  FutureBuilder<double>(
                    future: priceProvider.fetchCurrentPrice(_cryptoId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox(height: 20);
                      }

                      final price = snapshot.data ?? 0.0;
                      final balance =
                          double.tryParse('${widget.wallet['balance']}') ?? 0.0;
                      final fiatValue = price * balance;

                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '\$${NumberFormat('#,##0.00').format(fiatValue)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Price chart
            CryptoPriceChart(
              cryptoId: _cryptoId,
              symbol: _symbol,
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.arrow_upward,
                    label: 'Send',
                    onTap: () {
                      Navigator.pop(context, 'send');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.arrow_downward,
                    label: 'Receive',
                    onTap: () {
                      Navigator.pop(context, 'receive');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Transactions
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildTransactionsList(walletProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(WalletProvider walletProvider) {
    final transactions = walletProvider.transactions;
    final walletAddress = widget.wallet['address'];

    // Filter transactions for this specific wallet
    final filteredTransactions = transactions.where((tx) {
      return tx['from'] == walletAddress || tx['to'] == walletAddress;
    }).toList();

    // Sort transactions by date (newest first)
    filteredTransactions.sort((a, b) {
      final aDate = DateTime.parse(a['timestamp']);
      final bDate = DateTime.parse(b['timestamp']);
      return bDate.compareTo(aDate);
    });

    if (filteredTransactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No transactions yet'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        final isReceived = transaction['to'] == walletAddress;
        final date = DateTime.parse(transaction['timestamp']);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      (isReceived ? Colors.green : Colors.red).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isReceived ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReceived ? 'Received $_symbol' : 'Sent $_symbol',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy - HH:mm').format(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isReceived ? '+' : '-'}${transaction['value']} $_symbol',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isReceived ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
