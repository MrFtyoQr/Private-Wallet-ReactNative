import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double value) {
    final formatter = NumberFormat.simpleCurrency(locale: 'es_MX');
    return formatter.format(value);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
}
