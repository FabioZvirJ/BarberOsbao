class ClubeValidators {
  static bool isValidPoints(String value) {
    final parsed = int.tryParse(value.trim());
    return parsed != null && parsed > 0;
  }

  static bool isValidDate(String value) {
    final trimmed = value.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) {
      return false;
    }

    final date = DateTime.tryParse(trimmed);
    if (date == null) {
      return false;
    }

    final normalized = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return normalized == trimmed;
  }
}
