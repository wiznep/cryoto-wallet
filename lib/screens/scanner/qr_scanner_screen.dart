import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wallet_app/themes/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessingCode = false;
  bool _hasPermission = true;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _processScanResult(BarcodeCapture barcodes) async {
    if (_isProcessingCode) return;

    _isProcessingCode = true;

    try {
      final List<Barcode> codes = barcodes.barcodes;
      for (final barcode in codes) {
        final String? rawValue = barcode.rawValue;

        if (rawValue != null) {
          final String scannedData = rawValue.trim();

          // Check if it looks like a crypto address (basic validation)
          final bool isValidEthereumAddress =
              _validateEthereumAddress(scannedData);
          final bool isValidBitcoinAddress =
              _validateBitcoinAddress(scannedData);

          if (isValidEthereumAddress ||
              isValidBitcoinAddress ||
              _isValidUri(scannedData)) {
            // Play success haptic feedback if available
            // HapticFeedback.mediumImpact();

            // Return the scanned address
            Navigator.pop(context, scannedData);
            return;
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCode = false;
        });
      }
    }
  }

  bool _validateEthereumAddress(String address) {
    // Basic Ethereum address validation - starts with 0x and is 42 chars long
    return address.startsWith('0x') &&
        address.length == 42 &&
        RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address);
  }

  bool _validateBitcoinAddress(String address) {
    // Very basic Bitcoin address validation
    // Bitcoin addresses are typically between 26-35 characters
    // They start with 1, 3, or bc1
    return (address.length >= 26 && address.length <= 35) &&
        (address.startsWith('1') ||
            address.startsWith('3') ||
            address.startsWith('bc1'));
  }

  bool _isValidUri(String uri) {
    // Check if it's a URI with crypto schema like ethereum:0x...
    return uri.contains(':') &&
        (uri.startsWith('ethereum:') || uri.startsWith('bitcoin:'));
  }

  void _handlePermissionError() {
    setState(() {
      _hasPermission = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Camera permission denied. Please enable it in settings.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController.cameraFacingState,
              builder: (context, state, child) {
                return Icon(
                  state == CameraFacing.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                );
              },
            ),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _hasPermission
                ? MobileScanner(
                    controller: _scannerController,
                    onDetect: _processScanResult,
                    errorBuilder: (context, error, child) {
                      _handlePermissionError();
                      return _buildPermissionDeniedUI();
                    },
                    fit: BoxFit.cover,
                  )
                : _buildPermissionDeniedUI(),
          ),

          // Guidance text
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                const Text(
                  'Scan a QR code containing a wallet address',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Position the QR code within the scanning area',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedUI() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Camera permission required',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Please grant camera permission to scan QR codes',
                style: TextStyle(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
