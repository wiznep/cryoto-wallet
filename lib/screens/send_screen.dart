import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/providers/wallet_provider.dart';
import 'package:wallet_app/screens/scanner/qr_scanner_screen.dart';
import 'package:wallet_app/screens/transaction_detail_screen.dart';
import 'package:wallet_app/themes/app_theme.dart';
import 'dart:math' as math;

class SendScreen extends StatefulWidget {
  final Map<String, dynamic> wallet;

  const SendScreen({
    super.key,
    required this.wallet,
  });

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  bool _isAddressValid = true;

  double get _walletBalance {
    try {
      return double.parse(widget.wallet['balance'] ?? '0.0');
    } catch (e) {
      return 0.0;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _addressController.text = data!.text!;
      _validateAddress(data.text!);
    }
  }

  void _validateAddress(String value) {
    // This is a simplified validation - in a real app, use proper validation
    setState(() {
      _isAddressValid =
          value.isNotEmpty && value.startsWith('0x') && value.length == 42;
    });
  }

  Future<void> _scanQrCode() async {
    // Navigate to QR scanner screen and wait for result
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (result != null) {
      // Extract address from result (handle protocols like 'ethereum:0x...')
      String address = result;
      if (result.contains(':')) {
        final parts = result.split(':');
        if (parts.length > 1) {
          address = parts[1];
        }
      }

      setState(() {
        _addressController.text = address;
        _validateAddress(address);
      });
    }
  }

  Future<void> _sendTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // In a real app, connect to blockchain
        // Simulate network delay
        await Future.delayed(const Duration(seconds: 2));

        // Create a mock transaction
        final transaction = {
          'from': widget.wallet['address'],
          'to': _addressController.text,
          'value': _amountController.text,
          'timestamp': DateTime.now().toIso8601String(),
          'hash':
              '0x${List.generate(64, (index) => '0123456789abcdef'[math.Random().nextInt(16)]).join()}',
        };

        // Add the transaction to our provider
        final walletProvider =
            Provider.of<WalletProvider>(context, listen: false);
        // Add the transaction and show notification
        await walletProvider.addTransaction(transaction);

        if (mounted) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(
                transaction: transaction,
                walletAddress: widget.wallet['address'],
                cryptoType: widget.wallet['type'] ?? 'ETH',
              ),
            ),
          );
        }
      } catch (e) {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send ${widget.wallet['type'] ?? 'Crypto'}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Balance display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.wallet['balance']} ${widget.wallet['type'] ?? 'ETH'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Recipient address
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recipient Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: '0x...',
                      prefixIcon:
                          const Icon(Icons.account_balance_wallet_outlined),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.qr_code),
                            onPressed: _scanQrCode,
                          ),
                          IconButton(
                            icon: const Icon(Icons.paste),
                            onPressed: _pasteFromClipboard,
                          ),
                        ],
                      ),
                      errorText:
                          _addressController.text.isNotEmpty && !_isAddressValid
                              ? 'Invalid address format'
                              : null,
                    ),
                    onChanged: _validateAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a recipient address';
                      }
                      if (!_isAddressValid) {
                        return 'Invalid address format';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.monetization_on_outlined),
                      suffixIcon: TextButton(
                        onPressed: () {
                          _amountController.text = _walletBalance.toString();
                        },
                        child: Text(
                          'MAX',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }

                      try {
                        final amount = double.parse(value);
                        if (amount <= 0) {
                          return 'Amount must be greater than zero';
                        }
                        if (amount > _walletBalance) {
                          return 'Insufficient balance';
                        }
                      } catch (e) {
                        return 'Please enter a valid amount';
                      }

                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Network fee
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Network Fee',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const Text(
                      '0.0005 ETH',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Send button
              ElevatedButton(
                onPressed: _isLoading ? null : _sendTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
