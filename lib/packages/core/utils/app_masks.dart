import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formatter that automatically formats currency as user types:
/// Typing '5' -> '0,05'
/// Typing '50' -> '0,50'
/// Typing '500' -> '5,00'
/// Typing '5000' -> '50,00'
/// Typing '500000' -> '5.000,00'
class CurrencyInputFormatter extends TextInputFormatter {
  final int maxDigits;
  CurrencyInputFormatter({this.maxDigits = 10});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    if (digitsOnly.length > maxDigits) {
      digitsOnly = digitsOnly.substring(0, maxDigits);
    }

    final double value = (int.tryParse(digitsOnly) ?? 0) / 100.0;
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    final String formatted = formatter.format(value).trim();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for CPF (000.000.000-00)
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for Brazilian Phone ((XX) XXXXX-XXXX or (XX) XXXX-XXXX)
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (digits.length <= 10) {
        if (i == 6) buffer.write('-');
      } else {
        if (i == 7) buffer.write('-');
      }
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for Date (DD/MM/AAAA)
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for Percentage (0 to 100)
class PercentageInputFormatter extends TextInputFormatter {
  final int max;
  PercentageInputFormatter({this.max = 100});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }
    final int val = int.tryParse(digits) ?? 0;
    final int clamped = val > max ? max : val;
    final String text = clamped.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Centralized masks and parsing utilities
class AppMasks {
  AppMasks._();

  static final currency = CurrencyInputFormatter();
  static final cpf = CpfInputFormatter();
  static final phone = PhoneInputFormatter();
  static final date = DateInputFormatter();
  static final percentage = PercentageInputFormatter();
  static final digitsOnly = FilteringTextInputFormatter.digitsOnly;

  /// Parses a formatted currency string (e.g. "1.250,50" or "R$ 50,00") to double
  static double parseCurrency(String? text) {
    if (text == null || text.trim().isEmpty) return 0.0;
    final clean = text
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(clean) ?? 0.0;
  }

  /// Formats a number to mask format (e.g. 50.0 -> "50,00")
  static String formatCurrencyValue(num value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    ).format(value).trim();
  }

  /// Formats a raw CPF to 000.000.000-00
  static String formatCpf(String? cpf) {
    if (cpf == null || cpf.trim().isEmpty) return '';
    final digits = cpf.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return cpf;
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9, 11)}';
  }

  /// Formats raw phone to (XX) XXXXX-XXXX
  static String formatPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, 11)}';
    }
    if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6, 10)}';
    }
    return phone;
  }
}

/// Centralized form field validators
class AppValidators {
  AppValidators._();

  static FormFieldValidator<String> required(String fieldName) {
    return (val) {
      if (val == null || val.trim().isEmpty) {
        return '$fieldName é obrigatório(a)';
      }
      return null;
    };
  }

  static FormFieldValidator<String> currency({
    String fieldName = 'Preço',
    bool required = true,
    double min = 0.01,
  }) {
    return (val) {
      if (val == null || val.trim().isEmpty) {
        return required ? '$fieldName é obrigatório(a)' : null;
      }
      final parsed = AppMasks.parseCurrency(val);
      if (parsed < min) {
        return '$fieldName deve ser maior que zero';
      }
      return null;
    };
  }

  static FormFieldValidator<String> percentage({
    String fieldName = 'Porcentagem',
    bool required = true,
    int min = 0,
    int max = 100,
  }) {
    return (val) {
      if (val == null || val.trim().isEmpty) {
        return required ? '$fieldName é obrigatório(a)' : null;
      }
      final clean = val.replaceAll('%', '').replaceAll(',', '.').trim();
      final num = int.tryParse(clean);
      if (num == null) {
        return '$fieldName inválido(a)';
      }
      if (num < min || num > max) {
        return '$fieldName deve estar entre $min% e $max%';
      }
      return null;
    };
  }

  static FormFieldValidator<String> cpf({bool required = false}) {
    return (val) {
      if (val == null || val.trim().isEmpty) {
        return required ? 'CPF é obrigatório' : null;
      }
      final digits = val.replaceAll(RegExp(r'\D'), '');
      if (digits.length != 11) {
        return 'CPF deve conter 11 dígitos';
      }
      if (RegExp(r'^(\d)\1{10}$').hasMatch(digits)) {
        return 'CPF inválido';
      }
      return null;
    };
  }

  static FormFieldValidator<String> phone({bool required = true}) {
    return (val) {
      if (val == null || val.trim().isEmpty) {
        return required ? 'Telefone é obrigatório' : null;
      }
      final digits = val.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10 || digits.length > 11) {
        return 'Telefone deve ter 10 ou 11 dígitos com DDD';
      }
      return null;
    };
  }

  static FormFieldValidator<String> date({bool required = true}) {
    return (val) {
      if (val == null || val.trim().isEmpty) {
        return required ? 'Data é obrigatória' : null;
      }
      final parts = val.trim().split('/');
      if (parts.length != 3 || parts[0].length != 2 || parts[1].length != 2 || parts[2].length != 4) {
        return 'Data no formato DD/MM/AAAA';
      }
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) {
        return 'Data inválida';
      }
      if (month < 1 || month > 12) return 'Mês inválido';
      if (day < 1 || day > 31) return 'Dia inválido';
      if (year < 1920 || year > 2100) return 'Ano inválido';
      try {
        final d = DateTime(year, month, day);
        if (d.year != year || d.month != month || d.day != day) {
          return 'Data inexistente no calendário';
        }
      } catch (_) {
        return 'Data inválida';
      }
      return null;
    };
  }

  static FormFieldValidator<String> email({bool required = false}) {
    return (val) {
      if (val == null || val.trim().isEmpty) {
        return required ? 'E-mail é obrigatório' : null;
      }
      final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!regex.hasMatch(val.trim())) {
        return 'E-mail inválido';
      }
      return null;
    };
  }

  static FormFieldValidator<String> integer({
    String fieldName = 'Quantidade',
    bool required = true,
    int min = 0,
  }) {
    return (val) {
      if (val == null || val.trim().isEmpty) {
        return required ? '$fieldName é obrigatório(a)' : null;
      }
      final digits = val.replaceAll(RegExp(r'\D'), '');
      final num = int.tryParse(digits);
      if (num == null) {
        return '$fieldName deve ser um número inteiro';
      }
      if (num < min) {
        return '$fieldName deve ser no mínimo $min';
      }
      return null;
    };
  }
}
