import 'package:intl/intl.dart';

/// Indian digit grouping: 12,00,000 rather than 1,200,000.
final NumberFormat _inr = NumberFormat('#,##,##0.00', 'en_IN');
final NumberFormat _inrWhole = NumberFormat('#,##,##0', 'en_IN');

/// `12,00,000.00`
String money(num value) => _inr.format(value);

/// `12,00,000` — for figures where paise are noise.
String moneyWhole(num value) => _inrWhole.format(value);

/// `₹ 12,00,000.00`
String rupees(num value) => '₹ ${money(value)}';

/// Formats a 0–1 fraction as a percentage, e.g. 0.2011 → `20.11%`.
String percent(double fraction, {int decimals = 2}) =>
    '${(fraction * 100).toStringAsFixed(decimals)}%';

/// Durations are held as doubles, so a whole number arrives as "5.0".
/// `5.0 → "5"`, `2.5 → "2.5"`.
String years(Object value) {
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  if (parsed == null) return '$value';
  return parsed == parsed.roundToDouble()
      ? parsed.toInt().toString()
      : '$parsed';
}

/// Percentage with an explicit sign, e.g. `+150.0%` / `-12.5%`.
String signedPercent(double fraction, {int decimals = 1}) {
  final value = fraction * 100;
  final sign = value >= 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(decimals)}%';
}
