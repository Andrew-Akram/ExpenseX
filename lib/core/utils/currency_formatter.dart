import 'package:intl/intl.dart';

/// Currency formatting helpers.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _usd = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compact = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 1,
  );

  static final NumberFormat _plain = NumberFormat('#,##0.00');

  /// Format amount as '\$1,234.56'.
  static String format(double amount) => _usd.format(amount);

  /// Format as compact '\$1.2K' for chart labels.
  static String compact(double amount) => _compact.format(amount);

  /// Format without currency symbol: '1,234.56'.
  static String plain(double amount) => _plain.format(amount);

  /// Parse a string like '1,234.56' → 1234.56.
  static double? tryParse(String value) =>
      double.tryParse(value.replaceAll(',', '').replaceAll('\$', '').trim());
}
