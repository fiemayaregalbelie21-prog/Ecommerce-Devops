import 'package:intl/intl.dart';

class PriceFormatter {
  PriceFormatter._();

  static final NumberFormat _currency = NumberFormat.simpleCurrency();

  static String format(double price) => _currency.format(price);
}