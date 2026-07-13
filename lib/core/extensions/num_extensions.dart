import '../utils/currency_formatter.dart';

extension DoubleX on double {
  String get asCurrency => CurrencyFormatter.format(this);
  String get asCompact  => CurrencyFormatter.compact(this);
  String get asPlain    => CurrencyFormatter.plain(this);


  double get asFraction => clamp(0.0, 1.0).toDouble();
}

extension IntX on int {
  String get asCurrency => toDouble().asCurrency;
}
