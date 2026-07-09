import 'package:barber_osbao/features/funcionarios/domain/models/funcionario.dart';
import 'package:barber_osbao/features/funcionarios/domain/repositories/funcionarios_repository.dart';

class MockFuncionariosRepository implements FuncionariosRepository {
  final List<Funcionario> _funcionarios = [
    const Funcionario(
      id: 'barb_1',
      name: 'Marcos Silva',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&width=150',
      cargo: 'Barbeiro Master',
      phone: '(11) 98888-1111',
      email: 'marcos@barberosbao.com',
      cpf: '123.456.789-00',
      specialties: ['Corte Clássico', 'Barboterapia', 'Degradê'],
      commissionRate: 0.4, // 40%
      horarioTrabalho: '09:00 - 19:00',
      diasDisponiveis: ['Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'],
      folgas: ['Segunda', 'Domingo'],
      status: true,
      rating: 4.9,
    ),
    const Funcionario(
      id: 'barb_2',
      name: 'Arthur Santos',
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&width=150',
      cargo: 'Barbeiro Specialist',
      phone: '(11) 97777-2222',
      email: 'arthur@barberosbao.com',
      cpf: '234.567.890-11',
      specialties: ['Corte Moderno', 'Platinado', 'Design de Sobrancelha'],
      commissionRate: 0.35, // 35%
      horarioTrabalho: '10:00 - 20:00',
      diasDisponiveis: ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'],
      folgas: ['Domingo'],
      status: true,
      rating: 4.8,
    ),
    const Funcionario(
      id: 'barb_3',
      name: 'Gabriel Neves',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&width=150',
      cargo: 'Barbeiro Junior',
      phone: '(11) 96666-3333',
      email: 'gabriel@barberosbao.com',
      cpf: '345.678.901-22',
      specialties: ['Corte na Tesoura', 'Barba Tradicional'],
      commissionRate: 0.3, // 30%
      horarioTrabalho: '09:00 - 18:00',
      diasDisponiveis: ['Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'],
      folgas: ['Segunda', 'Terça'],
      status: true,
      rating: 4.7,
    ),
  ];

  @override
  Future<List<Funcionario>> getFuncionarios() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_funcionarios);
  }

  @override
  Future<Funcionario> createFuncionario(Funcionario funcionario) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newFunc = funcionario.copyWith(
      id: 'barb_${DateTime.now().millisecondsSinceEpoch}',
      rating: 5.0,
    );
    _funcionarios.add(newFunc);
    return newFunc;
  }

  @override
  Future<Funcionario> updateFuncionario(Funcionario funcionario) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _funcionarios.indexWhere((f) => f.id == funcionario.id);
    if (index != -1) {
      _funcionarios[index] = funcionario;
      return funcionario;
    }
    throw Exception('Funcionário não encontrado');
  }

  @override
  Future<void> deleteFuncionario(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _funcionarios.removeWhere((f) => f.id == id);
  }
}
