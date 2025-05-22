import 'package:flutter/material.dart';
import 'package:wallet_app/themes/app_theme.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _walletNameController = TextEditingController();
  final _seedPhraseController = TextEditingController();
  bool _isLoading = false;
  bool _hasReadTerms = false;
  bool _showSeedPhrase = false;

  @override
  void dispose() {
    _walletNameController.dispose();
    _seedPhraseController.dispose();
    super.dispose();
  }

  Future<void> _importWallet() async {
    if (!_formKey.currentState!.validate() || !_hasReadTerms) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and accept the terms'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, validate the seed phrase and import the wallet
      // This is a simplified demo
      await Future.delayed(const Duration(seconds: 2));

      // Return to previous screen with success message
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet imported successfully!'),
          ),
        );
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing wallet: $e'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Wallet'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              const SizedBox(height: 24),

              const Text(
                'Seed Phrase (Recovery Phrase)',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter your 12-word recovery phrase, separated by spaces',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _seedPhraseController,
                maxLines: 3,
                obscureText: !_showSeedPhrase,
                decoration: InputDecoration(
                  hintText: 'word1 word2 word3...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showSeedPhrase ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _showSeedPhrase = !_showSeedPhrase;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your seed phrase';
                  }

                  // Very basic validation - in a real app, do more thorough validation
                  final words = value.trim().split(' ');
                  if (words.length != 12 && words.length != 24) {
                    return 'Seed phrase must contain exactly 12 or 24 words';
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
                          'Security Warning',
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
                      'Never share your seed phrase with anyone. Anyone with your seed phrase can access your funds.',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        'Make sure you are in a private location before entering your seed phrase.'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              CheckboxListTile(
                value: _hasReadTerms,
                onChanged: (value) {
                  setState(() {
                    _hasReadTerms = value ?? false;
                  });
                },
                title: const Text(
                    'I accept the terms of service and privacy policy'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _importWallet,
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
                          'Import Wallet',
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
