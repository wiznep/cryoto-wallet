import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/themes/app_theme.dart';
import 'package:wallet_app/providers/price_provider.dart';
import 'package:wallet_app/screens/crypto/crypto_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:wallet_app/widgets/price_chart/crypto_price_chart.dart';

class BalanceCard extends StatefulWidget {
  final Map<String, dynamic> wallet;

  const BalanceCard({
    super.key,
    required this.wallet,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  late String _cryptoId;
  bool _showChart = false;
  double _priceChangePercent = 0.0;
  bool _isLoadingPriceChange = true;

  @override
  void initState() {
    super.initState();
    _initCryptoId();

    // Load price data
    Future.microtask(() async {
      final priceProvider = Provider.of<PriceProvider>(context, listen: false);
      await priceProvider.fetchCurrentPrice(_cryptoId);

      // Load price change percentage separately
      _loadPriceChangePercentage();
    });
  }

  Future<void> _loadPriceChangePercentage() async {
    try {
      final priceProvider = Provider.of<PriceProvider>(context, listen: false);
      // Use getPriceHistory instead of the get24hPriceChangePercentage method
      final history = await priceProvider.fetchPriceHistory(_cryptoId, 1);

      if (history.length >= 2) {
        final oldPrice = history.first.price;
        final currentPrice = history.last.price;

        if (oldPrice > 0) {
          if (mounted) {
            setState(() {
              _priceChangePercent =
                  ((currentPrice - oldPrice) / oldPrice) * 100;
              _isLoadingPriceChange = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingPriceChange = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPriceChange = false;
        });
      }
    }
  }

  void _initCryptoId() {
    final symbol = widget.wallet['type'] ?? 'ETH';
    switch (symbol.toLowerCase()) {
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
    final cryptoPrice = priceProvider.getCurrentPrice(_cryptoId);
    final balance = double.tryParse(widget.wallet['balance'].toString()) ?? 0.0;
    final fiatValue = balance * cryptoPrice;
    final symbol = widget.wallet['type'] ?? 'ETH';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CryptoDetailScreen(wallet: widget.wallet),
          ),
        );
      },
      child: Container(
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.wallet['balance']} ${widget.wallet['type'] ?? 'ETH'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (cryptoPrice > 0)
                      Text(
                        '\$${NumberFormat('#,##0.00').format(fiatValue)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showChart = !_showChart;
                    });
                  },
                  icon: Icon(
                    _showChart ? Icons.visibility_off : Icons.show_chart,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (_showChart) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: CryptoPriceChart(
                  cryptoId: _cryptoId,
                  symbol: symbol,
                  showLabels: false,
                  height: 120,
                  lineColor: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _isLoadingPriceChange
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      Icon(
                        _priceChangePercent >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_priceChangePercent >= 0 ? '+' : ''}${_priceChangePercent.toStringAsFixed(2)}% (24h)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
