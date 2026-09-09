import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/agenda/domain/models/agendamento.dart';
import 'package:barber_osbao/features/agenda/domain/repositories/agenda_repository.dart';
import 'package:barber_osbao/features/agenda/data/repositories/mock_agenda_repository.dart';

final agendaRepositoryProvider = Provider<AgendaRepository>((ref) {
  return MockAgendaRepository();
});

class AgendaController extends Notifier<AppState<List<Agendamento>>> {
  late final AgendaRepository _repository;

  @override
  AppState<List<Agendamento>> build() {
    _repository = ref.watch(agendaRepositoryProvider);
    Future.microtask(() => loadAgendamentos());
    return const AppLoading();
  }

  Future<void> loadAgendamentos() async {
    final currentData = state.data;
    if (currentData != null) {
      state = AppRefreshing(currentData);
    } else {
      state = const AppLoading();
    }

    try {
      final list = await _repository.getAgendamentos();
      if (list.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(list);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> addAgendamento(Agendamento agendamento) async {
    try {
      final currentData = state.data ?? [];
      final created = await _repository.createAgendamento(agendamento);
      state = AppSuccess([...currentData, created]);
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> editAgendamento(Agendamento agendamento) async {
    try {
      final currentData = state.data ?? [];
      final updated = await _repository.updateAgendamento(agendamento);
      state = AppSuccess(currentData.map((a) => a.id == agendamento.id ? updated : a).toList());
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> removeAgendamento(String id) async {
    try {
      final currentData = state.data ?? [];
      await _repository.deleteAgendamento(id);
      final updatedList = currentData.where((a) => a.id != id).toList();
      if (updatedList.isEmpty) {
        state = const AppEmpty();
      } else {
        state = AppSuccess(updatedList);
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      final currentData = state.data ?? [];
      final index = currentData.indexWhere((a) => a.id == id);
      if (index != -1) {
        final updated = currentData[index].copyWith(status: status);
        await _repository.updateAgendamento(updated);
        state = AppSuccess(currentData.map((a) => a.id == id ? updated : a).toList());
      }
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final agendaControllerProvider = NotifierProvider<AgendaController, AppState<List<Agendamento>>>(
  () => AgendaController(),
);
