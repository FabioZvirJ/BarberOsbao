import 'package:barber_osbao/features/servicos/domain/models/servico.dart';
import 'package:barber_osbao/features/servicos/domain/repositories/servicos_repository.dart';

class MockServicosRepository implements ServicosRepository {
  List<Servico> _servicos = [
    const Servico(
      id: 'srv_1',
      name: 'Corte de Cabelo',
      category: 'Cabelo',
      description: 'Corte completo com lavagem inclusa e finalização com pomada premium.',
      price: 45.0,
      durationMinutes: 30,
      imageUrl: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?q=80&width=150',
      colorHex: 'C89B3C', // Gold
      status: true,
    ),
    const Servico(
      id: 'srv_2',
      name: 'Barba Completa',
      category: 'Barba',
      description: 'Modelagem de barba com toalha quente, óleo hidratante e massagem facial.',
      price: 35.0,
      durationMinutes: 30,
      imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&width=150',
      colorHex: '22C55E', // Green
      status: true,
    ),
    const Servico(
      id: 'srv_3',
      name: 'Design de Sobrancelha',
      category: 'Sobrancelha',
      description: 'Limpeza e alinhamento de sobrancelha com navalha ou pinça.',
      price: 20.0,
      durationMinutes: 15,
      imageUrl: 'https://images.unsplash.com/photo-1605497746444-1ae02e21b764?q=80&width=150',
      colorHex: '3B82F6', // Blue
      status: true,
    ),
    const Servico(
      id: 'srv_4',
      name: 'Combo Cabelo + Barba',
      category: 'Combo',
      description: 'O serviço completo dos reis: corte personalizado e barba completa com toalha quente.',
      price: 70.0,
      durationMinutes: 60,
      imageUrl: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?q=80&width=150',
      colorHex: 'A855F7', // Purple
      status: true,
    ),
  ];

  @override
  Future<List<Servico>> getServicos() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_servicos);
  }

  @override
  Future<Servico> createServico(Servico servico) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newSrv = servico.copyWith(
      id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
    );
    _servicos.add(newSrv);
    return newSrv;
  }

  @override
  Future<Servico> updateServico(Servico servico) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _servicos.indexWhere((s) => s.id == servico.id);
    if (index != -1) {
      _servicos[index] = servico;
      return servico;
    }
    throw Exception('Serviço não encontrado');
  }

  @override
  Future<void> deleteServico(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _servicos.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> reorderServicos(List<Servico> servicos) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _servicos = List.from(servicos);
  }
}
