import 'package:flutter/material.dart';
import 'package:wallet_app/models/crypto_price_data.dart';
import 'package:wallet_app/services/price_service.dart';

class PriceProvider extends ChangeNotifier {
  final PriceService _priceService = PriceService();

  // Map to store current prices of cryptocurrencies
  final Map<String, double> _currentPrices = {};

  // Map to store price history for different cryptocurrencies and timeframes
  final Map<String, Map<int, List<CryptoPriceData>>> _priceHistory = {};

  // Loading states
  final Map<String, bool> _isLoadingPrice = {};
  final Map<String, Map<int, bool>> _isLoadingHistory = {};

  // Getters
  Map<String, double> get currentPrices => _currentPrices;

  bool isLoadingPrice(String cryptoId) => _isLoadingPrice[cryptoId] ?? false;

  bool isLoadingHistory(String cryptoId, int days) =>
      _isLoadingHistory[cryptoId]?[days] ?? false;

  // Get current price for a cryptocurrency
  double getCurrentPrice(String cryptoId) => _currentPrices[cryptoId] ?? 0.0;

  // Get price history for a cryptocurrency with specified timeframe
  List<CryptoPriceData> getPriceHistory(String cryptoId, int days) =>
      _priceHistory[cryptoId]?[days] ?? [];

  // Fetch current price
  Future<double> fetchCurrentPrice(String cryptoId) async {
    if (_isLoadingPrice[cryptoId] == true) {
      return _currentPrices[cryptoId] ?? 0.0;
    }

    _isLoadingPrice[cryptoId] = true;
    notifyListeners();

    try {
      final price = await _priceService.getCurrentPrice(cryptoId);
      _currentPrices[cryptoId] = price;
      return price;
    } catch (e) {
      debugPrint('Error fetching price for $cryptoId: $e');
      return 0.0;
    } finally {
      _isLoadingPrice[cryptoId] = false;
      notifyListeners();
    }
  }

  // Fetch price history
  Future<List<CryptoPriceData>> fetchPriceHistory(
      String cryptoId, int days) async {
    // Initialize nested maps if they don't exist yet
    _isLoadingHistory[cryptoId] ??= {};
    _priceHistory[cryptoId] ??= {};

    if (_isLoadingHistory[cryptoId]?[days] == true) {
      return _priceHistory[cryptoId]?[days] ?? [];
    }

    _isLoadingHistory[cryptoId]?[days] = true;
    notifyListeners();

    try {
      final history = await _priceService.getPriceHistory(cryptoId, days);
      _priceHistory[cryptoId]?[days] = history;
      return history;
    } catch (e) {
      debugPrint('Error fetching price history for $cryptoId: $e');
      return [];
    } finally {
      _isLoadingHistory[cryptoId]?[days] = false;
      notifyListeners();
    }
  }

  // Get 24h price change percentage
  Future<double> get24hPriceChangePercentage(String cryptoId) async {
    final history = await fetchPriceHistory(cryptoId, 1);

    if (history.length < 2) return 0.0;

    final oldPrice = history.first.price;
    final currentPrice = history.last.price;

    if (oldPrice == 0) return 0.0;

    return ((currentPrice - oldPrice) / oldPrice) * 100;
  }

  // Clear cached data
  void clearCache() {
    _currentPrices.clear();
    _priceHistory.clear();
    notifyListeners();
  }
}
