import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet_app/themes/app_theme.dart';
import 'package:wallet_app/utils/number_formatter.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String walletAddress;
  final String cryptoType;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.walletAddress,
    required this.cryptoType,
  });

  bool get isReceived => walletAddress == transaction['to'];

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(transaction['timestamp']);
    final formattedDate = formatDate(dateTime);
    final formattedTime =
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Transaction Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: isReceived
                  ? AppTheme.successColor.withOpacity(0.1)
                  : AppTheme.errorColor.withOpacity(0.1),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isReceived
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    child: Icon(
                      isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isReceived ? 'Received' : 'Sent',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${transaction['value']} $cryptoType',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isReceived
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$formattedDate at $formattedTime',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Transaction Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Status',
                    'Confirmed',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Confirmed',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    context,
                    'Transaction Hash',
                    _formatAddress(transaction['hash']),
                    isCopyable: true,
                    textToCopy: transaction['hash'],
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    context,
                    'From',
                    _formatAddress(transaction['from']),
                    isCopyable: true,
                    textToCopy: transaction['from'],
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    context,
                    'To',
                    _formatAddress(transaction['to']),
                    isCopyable: true,
                    textToCopy: transaction['to'],
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    context,
                    'Amount',
                    '${transaction['value']} $cryptoType',
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    context,
                    'Date',
                    '$formattedDate at $formattedTime',
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    context,
                    'Network Fee',
                    '0.0005 $cryptoType',
                  ),
                  _buildDivider(),
                ],
              ),
            ),

            // View on Explorer Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Open transaction in blockchain explorer
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppTheme.primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  child: const Text('View on Blockchain Explorer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAddress(String address) {
    if (address.length <= 15) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Widget? trailing,
    bool isCopyable = false,
    String? textToCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCopyable)
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: textToCopy ?? value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    visualDensity: VisualDensity.compact,
                  )
                else if (trailing != null)
                  trailing,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      height: 1,
    );
  }
}
