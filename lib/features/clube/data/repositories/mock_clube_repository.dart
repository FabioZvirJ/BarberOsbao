import 'package:barber_osbao/features/clube/domain/models/beneficio_clube.dart';
import 'package:barber_osbao/features/clube/domain/repositories/clube_repository.dart';

class MockClubeRepository implements ClubeRepository {
  List<BeneficioClube> _beneficios = [
    const BeneficioClube(
      id: 'b_1',
      name: 'Chopp Pilsen Gelado',
      description: 'Ganhe uma dose de chopp artesanal de 300ml na sua visita.',
      pointsRequired: 100,
      benefitValue: '1 Chopp Grátis',
      imageUrl: 'https://images.unsplash.com/photo-1571613316887-6f8d5cbf7ef7?q=80&width=150',
      expirationDate: '2026-12-31',
      active: true,
    ),
    const BeneficioClube(
      id: 'b_2',
      name: 'Pomada Matte Premium',
      description: 'Resgate uma pomada finalizadora modeladora premium do nosso estoque.',
      pointsRequired: 300,
      benefitValue: '1 Pomada Grátis',
      imageUrl: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&width=150',
      expirationDate: '2026-12-31',
      active: true,
    ),
    const BeneficioClube(
      id: 'b_3',
      name: '50% Desconto no Corte',
      description: 'Ganhe 50% de desconto em qualquer serviço de corte na tesoura ou máquina.',
      pointsRequired: 500,
      benefitValue: 'Corte pela metade do preço',
      imageUrl: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?q=80&width=150',
      expirationDate: '2026-10-31',
      active: true,
    ),
    const BeneficioClube(
      id: 'b_4',
      name: 'Serviço Imperial Completo',
      description: 'A experiência de rei completa grátis: corte, barba, sobrancelha e toalha quente.',
      pointsRequired: 800,
      benefitValue: 'Combo Cabelo+Barba+Sobrancelha Grátis',
      imageUrl: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?q=80&width=150',
      expirationDate: '2026-08-31',
      active: false,
    ),
  ];

  @override
  Future<List<BeneficioClube>> getBeneficios() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_beneficios);
  }

  @override
  Future<BeneficioClube> createBeneficio(BeneficioClube beneficio) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newB = beneficio.copyWith(
      id: 'b_${DateTime.now().millisecondsSinceEpoch}',
    );
    _beneficios.add(newB);
    return newB;
  }

  @override
  Future<BeneficioClube> updateBeneficio(BeneficioClube beneficio) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _beneficios.indexWhere((b) => b.id == beneficio.id);
    if (index != -1) {
      _beneficios[index] = beneficio;
      return beneficio;
    }
    throw Exception('Benefício não encontrado');
  }

  @override
  Future<void> deleteBeneficio(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _beneficios.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> reorderBeneficios(List<BeneficioClube> list) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _beneficios = List.from(list);
  }
}
