import 'package:barber_osbao/features/agenda/domain/models/agendamento.dart';
import 'package:barber_osbao/features/agenda/domain/repositories/agenda_repository.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class HttpAgendaRepository implements AgendaRepository {
  final DioClient _dioClient;

  HttpAgendaRepository(this._dioClient);

  @override
  Future<List<Agendamento>> getAgendamentos() async {
    final response = await _dioClient.dio.get('/appointments');
    final data = response.data as List;
    return data.map((json) => Agendamento.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Agendamento> createAgendamento(Agendamento agendamento) async {
    final response = await _dioClient.dio.post(
      '/appointments',
      data: {
        'clientName': agendamento.clientName,
        'barberName': agendamento.barberName,
        'serviceName': agendamento.services,
        'services': agendamento.services,
        'date': agendamento.date,
        'time': agendamento.time,
        'price': agendamento.price,
        'status': agendamento.status,
        'notes': agendamento.notes,
      },
    );
    return Agendamento.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Agendamento> updateAgendamento(Agendamento agendamento) async {
    final response = await _dioClient.dio.put(
      '/appointments/${agendamento.id}',
      data: {
        'clientName': agendamento.clientName,
        'barberName': agendamento.barberName,
        'serviceName': agendamento.services,
        'services': agendamento.services,
        'date': agendamento.date,
        'time': agendamento.time,
        'price': agendamento.price,
        'status': agendamento.status,
        'notes': agendamento.notes,
      },
    );
    return Agendamento.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAgendamento(String id) async {
    await _dioClient.dio.delete('/appointments/$id');
  }
}

