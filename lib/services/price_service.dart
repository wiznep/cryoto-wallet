import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wallet_app/models/crypto_price_data.dart';

class PriceService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  // Fetch current price for a cryptocurrency
  Future<double> getCurrentPrice(String cryptoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/simple/price?ids=$cryptoId&vs_currencies=usd'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data[cryptoId]['usd'].toDouble();
      }
      throw Exception('Failed to load price data');
    } catch (e) {
      // Return mock price for demo
      return _getMockCurrentPrice(cryptoId);
    }
  }

  // Fetch price history for a cryptocurrency
  Future<List<CryptoPriceData>> getPriceHistory(
    String cryptoId,
    int days,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/coins/$cryptoId/market_chart?vs_currency=usd&days=$days'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prices = data['prices'] as List;

        return prices.map((pricePoint) {
          return CryptoPriceData(
            date: DateTime.fromMillisecondsSinceEpoch(pricePoint[0].toInt()),
            price: pricePoint[1].toDouble(),
          );
        }).toList();
      }
      throw Exception('Failed to load price history');
    } catch (e) {
      // Return mock data for demo
      return _getMockPriceHistory(cryptoId, days);
    }
  }

  // Mock current price for demo purposes
  double _getMockCurrentPrice(String cryptoId) {
    switch (cryptoId.toLowerCase()) {
      case 'bitcoin':
        return 57893.42;
      case 'ethereum':
        return 3241.78;
      case 'binancecoin':
        return 532.91;
      case 'solana':
        return 140.23;
      default:
        return 100.0;
    }
  }

  // Generate mock price history data for demo purposes
  List<CryptoPriceData> _getMockPriceHistory(String cryptoId, int days) {
    final List<CryptoPriceData> result = [];
    final now = DateTime.now();
    double basePrice = 0;

    // Set base price based on crypto
    switch (cryptoId.toLowerCase()) {
      case 'bitcoin':
        basePrice = 55000;
        break;
      case 'ethereum':
        basePrice = 3000;
        break;
      case 'binancecoin':
        basePrice = 500;
        break;
      case 'solana':
        basePrice = 130;
        break;
      default:
        basePrice = 100;
    }

    // Generate price points with some volatility
    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Add some random variance to create a realistic looking price chart
      final variance = (basePrice * 0.2) * (0.5 - _pseudoRandom(i, cryptoId));
      final price = basePrice + variance;

      result.add(CryptoPriceData(date: date, price: price));

      // Slightly adjust the base price for the next data point
      basePrice += basePrice * _pseudoRandom(i, cryptoId) * 0.02;
    }

    return result;
  }

  // Pseudo-random function that gives consistent results for same inputs
  double _pseudoRandom(int seed, String text) {
    final combinedSeed = seed + text.codeUnits.reduce((a, b) => a + b);
    return (combinedSeed * 9301 + 49297) % 233280 / 233280;
  }
}
