import 'package:flutter/material.dart';
import 'package:wallet_app/themes/app_theme.dart';
import 'dart:math' as math;

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _walletNameController = TextEditingController();
  bool _isLoading = false;
  bool _hasBackedUpSeedPhrase = false;
  bool _understandsRisks = false;
  bool _hasReadTerms = false;

  @override
  void dispose() {
    _walletNameController.dispose();
    super.dispose();
  }

  Future<void> _createWallet() async {
    if (!_formKey.currentState!.validate() ||
        !_hasBackedUpSeedPhrase ||
        !_understandsRisks ||
        !_hasReadTerms) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please fill all required fields and check all agreements'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate a mock wallet for demo purposes
      // In a real app, this would use cryptographic methods to generate a new wallet

      // Demo seed phrase for illustration - in a real app, generate this securely
      final mockSeedPhrase =
          'zoo kiwi pride detail flame clean scare pet canvas peanut dizzy theme';

      // Demo wallet address - in a real app, derive this from the seed phrase
      final walletAddress =
          '0x${List.generate(40, (index) => '0123456789abcdef'[index % 16]).join()}';

      // Navigate to success screen
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet created successfully!'),
          ),
        );
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating wallet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Wallet'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet name field
              const Text(
                'Wallet Name',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _walletNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter wallet name',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for your wallet';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Security information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Security Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'After creating your wallet, you will be shown a seed phrase (recovery phrase). It\'s extremely important to:',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        '• Write it down and store it in a secure place'),
                    const Text('• Never share it with anyone'),
                    const Text(
                        '• If you lose it, you lose access to your funds'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Checkboxes for agreements
              CheckboxListTile(
                value: _hasBackedUpSeedPhrase,
                onChanged: (value) {
                  setState(() {
                    _hasBackedUpSeedPhrase = value ?? false;
                  });
                },
                title:
                    const Text('I understand I need to back up my seed phrase'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              CheckboxListTile(
                value: _understandsRisks,
                onChanged: (value) {
                  setState(() {
                    _understandsRisks = value ?? false;
                  });
                },
                title: const Text(
                    'I understand the risks of losing my seed phrase'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              CheckboxListTile(
                value: _hasReadTerms,
                onChanged: (value) {
                  setState(() {
                    _hasReadTerms = value ?? false;
                  });
                },
                title: const Text(
                    'I have read and agreed to the Terms of Service'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 32),

              // Create button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createWallet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
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
                      : const Text(
                          'Create Wallet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
