import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wallet_app/models/crypto_price_data.dart';
import 'package:wallet_app/providers/price_provider.dart';
import 'package:wallet_app/themes/app_theme.dart';

class CryptoPriceChart extends StatefulWidget {
  final String cryptoId;
  final String symbol;
  final Color lineColor;
  final bool showLabels;
  final double height;

  const CryptoPriceChart({
    super.key,
    required this.cryptoId,
    required this.symbol,
    this.lineColor = AppTheme.primaryColor,
    this.showLabels = true,
    this.height = 250,
  });

  @override
  State<CryptoPriceChart> createState() => _CryptoPriceChartState();
}

class _CryptoPriceChartState extends State<CryptoPriceChart> {
  int _selectedTimeframe = 7; // Default: 7 days
  List<CryptoPriceData> _priceData = [];
  bool _isLoading = false;
  final List<int> _timeframeOptions = [1, 7, 30, 90, 365];

  @override
  void initState() {
    super.initState();
    _loadPriceData();
  }

  Future<void> _loadPriceData() async {
    setState(() {
      _isLoading = true;
    });

    final priceProvider = Provider.of<PriceProvider>(context, listen: false);
    final priceData = await priceProvider.fetchPriceHistory(
      widget.cryptoId,
      _selectedTimeframe,
    );

    // Also fetch current price
    await priceProvider.fetchCurrentPrice(widget.cryptoId);

    if (mounted) {
      setState(() {
        _priceData = priceData;
        _isLoading = false;
      });
    }
  }

  void _changeTimeframe(int days) {
    setState(() {
      _selectedTimeframe = days;
    });
    _loadPriceData();
  }

  @override
  Widget build(BuildContext context) {
    final priceProvider = Provider.of<PriceProvider>(context);
    final currentPrice = priceProvider.getCurrentPrice(widget.cryptoId);

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.symbol} Price',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${NumberFormat('#,##0.00').format(currentPrice)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              FutureBuilder<double>(
                future:
                    priceProvider.get24hPriceChangePercentage(widget.cryptoId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      width: 80,
                      height: 30,
                      child: Center(
                        child: SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final change = snapshot.data ?? 0.0;
                  final isPositive = change >= 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isPositive ? Colors.green : Colors.red)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: isPositive ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _priceData.isEmpty
                    ? const Center(child: Text('No price data available'))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: widget.showLabels,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() %
                                          (_priceData.length ~/ 5) !=
                                      0) {
                                    return const SizedBox();
                                  }

                                  final index = value.toInt();
                                  if (index < 0 || index >= _priceData.length) {
                                    return const SizedBox();
                                  }

                                  final date = _priceData[index].date;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      DateFormat(_selectedTimeframe <= 7
                                              ? 'E'
                                              : 'MM/dd')
                                          .format(date),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _priceData.asMap().entries.map((entry) {
                                return FlSpot(
                                    entry.key.toDouble(), entry.value.price);
                              }).toList(),
                              isCurved: true,
                              color: widget.lineColor,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: widget.lineColor.withOpacity(0.2),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.8),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final index = spot.x.toInt();
                                  if (index < 0 || index >= _priceData.length) {
                                    return null;
                                  }

                                  final price = _priceData[index].price;
                                  final date = _priceData[index].date;

                                  return LineTooltipItem(
                                    '${DateFormat('MMM dd, yyyy').format(date)}\n',
                                    TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '\$${NumberFormat('#,##0.00').format(price)}',
                                        style: TextStyle(
                                          color: widget.lineColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
          ),

          // Timeframe selector
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _timeframeOptions.map((days) {
              final isSelected = _selectedTimeframe == days;
              final label = days == 1
                  ? '1D'
                  : days == 7
                      ? '1W'
                      : days == 30
                          ? '1M'
                          : days == 90
                              ? '3M'
                              : days == 365
                                  ? '1Y'
                                  : '${days}D';

              return GestureDetector(
                onTap: () => _changeTimeframe(days),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.lineColor
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? widget.lineColor
                          : Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
