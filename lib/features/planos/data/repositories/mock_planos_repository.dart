import 'package:barber_osbao/features/planos/domain/models/plano.dart';
import 'package:barber_osbao/features/planos/domain/repositories/planos_repository.dart';

class MockPlanosRepository implements PlanosRepository {
  final List<Plano> _planos = [
    const Plano(
      id: 'plan_1',
      name: 'Plano Cavalheiro',
      price: 89.90,
      period: 'mensal',
      benefits: [
        'Até 2 cortes de cabelo por mês',
        'Reserva online com prioridade',
        '1 dose de Chopp cortesia por visita',
      ],
      cutsCount: 2,
      productDiscount: 0.0,
      status: true,
      recommended: false,
    ),
    const Plano(
      id: 'plan_2',
      name: 'Plano Barão',
      price: 139.90,
      period: 'mensal',
      benefits: [
        'Cortes de cabelo ilimitados',
        'Até 2 barbas por mês',
        'Chopp e água liberados',
        '10% de desconto em produtos',
      ],
      cutsCount: 9999, // Unlimited
      productDiscount: 0.10,
      status: true,
      recommended: true,
    ),
    const Plano(
      id: 'plan_3',
      name: 'Plano Imperial',
      price: 199.90,
      period: 'mensal',
      benefits: [
        'Cabelo e barba ilimitados',
        'Sobrancelha inclusa',
        'Atendimento exclusivo VIP sem fila',
        'Bebidas liberadas no bar',
        '15% de desconto em produtos',
      ],
      cutsCount: 9999, // Unlimited
      productDiscount: 0.15,
      status: true,
      recommended: false,
    ),
  ];

  @override
  Future<List<Plano>> getPlanos() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_planos);
  }

  @override
  Future<Plano> createPlano(Plano plano) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newPlano = plano.copyWith(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
    );
    _planos.add(newPlano);
    return newPlano;
  }

  @override
  Future<Plano> updatePlano(Plano plano) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _planos.indexWhere((p) => p.id == plano.id);
    if (index != -1) {
      _planos[index] = plano;
      return plano;
    }
    throw Exception('Plano não encontrado');
  }

  @override
  Future<void> deletePlano(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _planos.removeWhere((p) => p.id == id);
  }
}
