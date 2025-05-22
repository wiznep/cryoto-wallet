import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/providers/wallet_provider.dart';
import 'package:wallet_app/screens/transaction_detail_screen.dart';
import 'package:wallet_app/themes/app_theme.dart';
import 'package:wallet_app/widgets/home/wallet_list_item.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> wallet;

  const TransactionHistoryScreen({
    super.key,
    required this.wallet,
  });

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filterType = 'all'; // all, sent, received

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final transactions = walletProvider.transactions;
    final walletAddress = widget.wallet['address'];

    // Filter transactions based on selected filter
    final filteredTransactions = transactions.where((tx) {
      if (_filterType == 'all') return true;
      if (_filterType == 'sent') return tx['from'] == walletAddress;
      if (_filterType == 'received') return tx['to'] == walletAddress;
      return true;
    }).toList();

    // Sort transactions by date (newest first)
    filteredTransactions.sort((a, b) {
      final aDate = DateTime.parse(a['timestamp']);
      final bDate = DateTime.parse(b['timestamp']);
      return bDate.compareTo(aDate);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Received', 'received'),
                _buildFilterChip('Sent', 'sent'),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 64,
                          color: AppTheme.secondaryTextColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => walletProvider.refreshBalance(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        final isReceived = transaction['to'] == walletAddress;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailScreen(
                                  transaction: transaction,
                                  walletAddress: walletAddress,
                                  cryptoType: widget.wallet['type'] ?? 'ETH',
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
                                '${transaction['value']} ${widget.wallet['type'] ?? 'ETH'}',
                            isPositive: isReceived,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = _filterType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
