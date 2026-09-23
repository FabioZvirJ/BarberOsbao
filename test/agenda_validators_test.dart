import 'package:flutter_test/flutter_test.dart';
import 'package:barber_osbao/features/agenda/presentation/utils/agenda_validators.dart';

void main() {
  group('Agenda validators', () {
    test('aceita data, hora e valor válidos', () {
      expect(
        AgendaValidators.isValidDate('2026-09-22'),
        isTrue,
      );
      expect(
        AgendaValidators.isValidTime('09:45'),
        isTrue,
      );
      expect(
        AgendaValidators.isValidPrice('125.50'),
        isTrue,
      );
    });

    test('rejeita data, hora e valor inválidos', () {
      expect(
        AgendaValidators.isValidDate('2026-02-30'),
        isFalse,
      );
      expect(
        AgendaValidators.isValidTime('25:99'),
        isFalse,
      );
      expect(
        AgendaValidators.isValidPrice(r'R$ 125,50'),
        isFalse,
      );
    });

    test('detecta conflito de agenda com sobreposição de tempo', () {
      final hasConflict = AgendaValidators.hasScheduleConflict(
        barberName: 'Marcos Silva',
        date: '2026-09-22',
        time: '09:30',
        durationMinutes: 60,
        existingAppointments: [
          const AgendaAppointmentSnapshot(
            barberName: 'Marcos Silva',
            date: '2026-09-22',
            time: '09:00',
            durationMinutes: 60,
          ),
        ],
      );

      expect(hasConflict, isTrue);
    });
  });
}
