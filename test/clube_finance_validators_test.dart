import 'package:flutter_test/flutter_test.dart';
import 'package:barber_osbao/features/clube/presentation/utils/clube_validators.dart';
import 'package:barber_osbao/features/financeiro/presentation/utils/financeiro_validators.dart';

void main() {
  group('Clube validators', () {
    test('aceita recompensas válidas e rejeita pontos inválidos', () {
      expect(ClubeValidators.isValidPoints('100'), isTrue);
      expect(ClubeValidators.isValidPoints('0'), isFalse);
      expect(ClubeValidators.isValidDate('2026-12-31'), isTrue);
      expect(ClubeValidators.isValidDate('31-12-2026'), isFalse);
    });
  });

  group('Financeiro validators', () {
    test('aceita valores e datas válidas e rejeita entradas inconsistentes', () {
      expect(FinanceiroValidators.isValidAmount('125.50'), isTrue);
      expect(FinanceiroValidators.isValidAmount('-10'), isFalse);
      expect(FinanceiroValidators.isValidDate('2026-07-09'), isTrue);
      expect(FinanceiroValidators.isValidDate('2026-02-30'), isFalse);
      expect(FinanceiroValidators.isValidDescription('Pagamento de corte'), isTrue);
      expect(FinanceiroValidators.isValidDescription('   '), isFalse);
    });
  });
}
