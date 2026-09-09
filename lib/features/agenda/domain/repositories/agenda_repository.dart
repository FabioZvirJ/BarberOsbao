import 'package:barber_osbao/features/agenda/domain/models/agendamento.dart';

abstract class AgendaRepository {
  Future<List<Agendamento>> getAgendamentos();
  Future<Agendamento> createAgendamento(Agendamento agendamento);
  Future<Agendamento> updateAgendamento(Agendamento agendamento);
  Future<void> deleteAgendamento(String id);
}
