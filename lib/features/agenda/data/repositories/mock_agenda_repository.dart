import 'package:barber_osbao/features/agenda/domain/models/agendamento.dart';
import 'package:barber_osbao/features/agenda/domain/repositories/agenda_repository.dart';

class MockAgendaRepository implements AgendaRepository {
  final List<Agendamento> _agendamentos = [
    const Agendamento(
      id: 'apt_1',
      clientName: 'João Silva',
      barberName: 'Marcos Silva',
      services: 'Corte + Barba',
      date: '2026-07-09',
      time: '09:00',
      price: 80.0,
      status: 'confirmed',
      notes: 'Degradê na máquina 2.',
    ),
    const Agendamento(
      id: 'apt_2',
      clientName: 'Carlos Oliveira',
      barberName: 'Arthur Santos',
      services: 'Corte Degradê',
      date: '2026-07-09',
      time: '10:30',
      price: 45.0,
      status: 'confirmed',
      notes: 'Cortar em cima com tesoura.',
    ),
    const Agendamento(
      id: 'apt_3',
      clientName: 'Mateus Santos',
      barberName: 'Gabriel Neves',
      services: 'Barba Tradicional',
      date: '2026-07-09',
      time: '13:00',
      price: 35.0,
      status: 'completed',
      notes: 'Toalha quente.',
    ),
    const Agendamento(
      id: 'apt_4',
      clientName: 'Pedro Almeida',
      barberName: 'Marcos Silva',
      services: 'Corte + Barba + Sobrancelha',
      date: '2026-07-09',
      time: '14:30',
      price: 120.0,
      status: 'pending',
      notes: 'Primeira vez no salão.',
    ),
    const Agendamento(
      id: 'apt_5',
      clientName: 'Lucas Lima',
      barberName: 'Arthur Santos',
      services: 'Platinado Completo',
      date: '2026-07-10', // tomorrow
      time: '09:00',
      price: 150.0,
      status: 'confirmed',
      notes: 'Descoloração global.',
    ),
    const Agendamento(
      id: 'apt_6',
      clientName: 'Guilherme Rocha',
      barberName: 'Gabriel Neves',
      services: 'Corte Tesoura',
      date: '2026-07-11', // this week
      time: '11:00',
      price: 55.0,
      status: 'confirmed',
      notes: 'Corte social clássico.',
    ),
    const Agendamento(
      id: 'apt_7',
      clientName: 'Fabio Zvir',
      barberName: 'Marcos Silva',
      services: 'Barba Completa',
      date: '2026-07-12',
      time: '16:00',
      price: 35.0,
      status: 'cancelled',
      notes: 'Compromisso de última hora.',
    ),
  ];

  @override
  Future<List<Agendamento>> getAgendamentos() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_agendamentos);
  }

  @override
  Future<Agendamento> createAgendamento(Agendamento agendamento) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newApt = agendamento.copyWith(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
    );
    _agendamentos.add(newApt);
    return newApt;
  }

  @override
  Future<Agendamento> updateAgendamento(Agendamento agendamento) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _agendamentos.indexWhere((a) => a.id == agendamento.id);
    if (index != -1) {
      _agendamentos[index] = agendamento;
      return agendamento;
    }
    throw Exception('Agendamento não encontrado');
  }

  @override
  Future<void> deleteAgendamento(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _agendamentos.removeWhere((a) => a.id == id);
  }
}
