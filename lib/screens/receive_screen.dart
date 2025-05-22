import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet_app/themes/app_theme.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReceiveScreen extends StatefulWidget {
  final Map<String, dynamic> wallet;

  const ReceiveScreen({
    super.key,
    required this.wallet,
  });

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSharingLoading = false;

  String get _walletAddress => widget.wallet['address'] ?? '';
  String get _cryptoType => widget.wallet['type'] ?? 'ETH';

  Future<void> _shareAddress() async {
    // Simple text sharing of the wallet address
    try {
      setState(() {
        _isSharingLoading = true;
      });

      final text = 'My $_cryptoType wallet address: $_walletAddress';
      await Share.share(text);
    } finally {
      if (mounted) {
        setState(() {
          _isSharingLoading = false;
        });
      }
    }
  }

  Future<void> _shareQRCode() async {
    try {
      setState(() {
        _isSharingLoading = true;
      });

      // Capture QR code as image
      final qrBoundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (qrBoundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to capture QR code')),
        );
        return;
      }

      // Convert to image
      final qrImage = await qrBoundary.toImage(pixelRatio: 3.0);
      final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qrcode.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());

        // Share the image file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'My $_cryptoType wallet address: $_walletAddress',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing QR code: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharingLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receive $_cryptoType'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Scan QR code to receive $_cryptoType',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 32),

              // QR code
              RepaintBoundary(
                key: _qrKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: _walletAddress,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    gapless: false,
                    errorStateBuilder: (context, error) {
                      return Container(
                        width: 220,
                        height: 220,
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            'Error generating QR code',
                            style: TextStyle(
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Wallet name
              Text(
                widget.wallet['name'] ?? 'My Wallet',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Wallet address with copy button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatAddress(_walletAddress),
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _walletAddress));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Address copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy address',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Information note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Only send $_cryptoType to this address. Sending any other cryptocurrency may result in permanent loss.',
                        style: TextStyle(
                          color: AppTheme.warningColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Share buttons
              Row(
                children: [
                  // Share address button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSharingLoading ? null : _shareAddress,
                      icon: const Icon(Icons.text_fields),
                      label: const Text('Share Address'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppTheme.primaryColor,
                        elevation: 0,
                        side: BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Share QR code button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSharingLoading ? null : _shareQRCode,
                      icon: _isSharingLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.qr_code),
                      label: const Text('Share QR Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(String address) {
    if (address.length <= 15) return address;
    return '${address.substring(0, 10)}...${address.substring(address.length - 8)}';
  }
}
