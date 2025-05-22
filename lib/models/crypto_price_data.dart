class CryptoPriceData {
  final DateTime date;
  final double price;

  CryptoPriceData({required this.date, required this.price});

  factory CryptoPriceData.fromJson(Map<String, dynamic> json) {
    return CryptoPriceData(
      date: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': date.millisecondsSinceEpoch,
      'price': price,
    };
  }
}
