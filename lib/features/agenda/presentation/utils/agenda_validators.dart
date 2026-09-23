class AgendaAppointmentSnapshot {
  final String barberName;
  final String date;
  final String time;
  final int durationMinutes;

  const AgendaAppointmentSnapshot({
    required this.barberName,
    required this.date,
    required this.time,
    required this.durationMinutes,
  });
}

class AgendaValidators {
  static bool isValidDate(String? value) {
    if (value == null || value.trim().isEmpty) return false;

    final formatted = value.trim();
    final match = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(formatted);
    if (!match) return false;

    final parsed = DateTime.tryParse(formatted);
    if (parsed == null) return false;

    final normalized =
        '${parsed.year.toString().padLeft(4, '0')}-'
        '${parsed.month.toString().padLeft(2, '0')}-'
        '${parsed.day.toString().padLeft(2, '0')}';

    return normalized == formatted;
  }

  static bool isValidTime(String? value) {
    if (value == null || value.trim().isEmpty) return false;

    final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').hasMatch(value.trim());
    if (!match) return false;

    final parts = value.trim().split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    return hour != null && minute != null && hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  static bool isValidPrice(String? value) {
    if (value == null || value.trim().isEmpty) return false;

    final normalized = value.trim().replaceAll(',', '.');
    final match = RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalized);
    if (!match) return false;

    return double.tryParse(normalized) != null;
  }

  static String normalizePriceText(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^\d,\.]'), '');
    if (sanitized.isEmpty) return '';

    final normalized = sanitized.replaceAll(',', '.');
    final number = double.tryParse(normalized);
    if (number == null) return sanitized;

    return number.toStringAsFixed(2);
  }

  static bool hasScheduleConflict({
    required String barberName,
    required String date,
    required String time,
    required int durationMinutes,
    required List<AgendaAppointmentSnapshot> existingAppointments,
  }) {
    if (!isValidDate(date) || !isValidTime(time)) return false;

    final startMinutes = _timeToMinutes(time);
    final endMinutes = startMinutes + durationMinutes;

    for (final appointment in existingAppointments) {
      if (appointment.barberName != barberName || appointment.date != date) {
        continue;
      }

      final currentStart = _timeToMinutes(appointment.time);
      final currentEnd = currentStart + appointment.durationMinutes;

      final overlap = startMinutes < currentEnd && endMinutes > currentStart;
      if (overlap) {
        return true;
      }
    }

    return false;
  }

  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.tryParse(parts.first) ?? 0;
    final minutes = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return hours * 60 + minutes;
  }
}
