import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat.decimalPattern('pt_BR');

  /// Formats a number to Brazilian currency: R$ 1.250,50
  static String formatCurrency(num value) {
    return _currencyFormat.format(value).trim();
  }

  /// Formats a number to pt_BR decimal/integer format: 1.250 or 1.250,50
  static String formatNumber(num value) {
    return _numberFormat.format(value);
  }

  /// Formats date YYYY-MM-DD or DateTime to DD/MM/YYYY
  static String formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
    }
    if (date is String) {
      final trimmed = date.trim();
      if (trimmed.isEmpty) return '';
      if (trimmed.contains('-')) {
        final parts = trimmed.split('-');
        if (parts.length == 3) {
          // If YYYY-MM-DD
          if (parts[0].length == 4) {
            return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
          }
        }
      }
      return trimmed;
    }
    return date.toString();
  }

  /// Formats a time string (HH:mm) or DateTime to HH:mm
  static String formatTime(dynamic time) {
    if (time == null) return '';
    if (time is DateTime) {
      return DateFormat('HH:mm').format(time);
    }
    if (time is String) {
      final trimmed = time.trim();
      if (trimmed.isEmpty) return '';
      final parts = trimmed.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return trimmed;
    }
    return time.toString();
  }

  /// Formats DateTime or date string to DD/MM/YYYY HH:mm
  static String formatDateTime(dynamic dt) {
    if (dt == null) return '';
    if (dt is DateTime) {
      return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(dt);
    }
    if (dt is String) {
      final parsed = DateTime.tryParse(dt);
      if (parsed != null) {
        return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(parsed);
      }
      return dt;
    }
    return dt.toString();
  }

  /// Extracts 1 or 2 uppercase initials from a full name (e.g. "Jean Talar" -> "JT")
  static String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
