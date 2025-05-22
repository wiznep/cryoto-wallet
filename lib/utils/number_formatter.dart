import 'package:intl/intl.dart';

/// Format a number to a currency string with 2 decimal places
String formatCurrency(dynamic value) {
  if (value == null) return '0.00';

  try {
    final numValue =
        value is String ? double.parse(value) : (value as num).toDouble();
    return numValue.toStringAsFixed(2);
  } catch (e) {
    return '0.00';
  }
}

/// Format a number with thousands separators
String formatNumber(dynamic value) {
  if (value == null) return '0';

  try {
    final formatter = NumberFormat('#,###.##');
    final numValue =
        value is String ? double.parse(value) : (value as num).toDouble();
    return formatter.format(numValue);
  } catch (e) {
    return '0';
  }
}

/// Format a large number to compact form (e.g. 1.2K, 1.2M)
String formatCompactNumber(dynamic value) {
  if (value == null) return '0';

  try {
    final formatter = NumberFormat.compact();
    final numValue =
        value is String ? double.parse(value) : (value as num).toDouble();
    return formatter.format(numValue);
  } catch (e) {
    return '0';
  }
}

/// Format a percentage with a specified number of decimal places
String formatPercent(dynamic value, {int decimalPlaces = 2}) {
  if (value == null) return '0%';

  try {
    final numValue =
        value is String ? double.parse(value) : (value as num).toDouble();
    return '${numValue.toStringAsFixed(decimalPlaces)}%';
  } catch (e) {
    return '0%';
  }
}

/// Format a date to a readable string
String formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
