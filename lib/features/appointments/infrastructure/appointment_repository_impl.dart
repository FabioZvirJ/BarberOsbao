import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/storage/drift_db.dart';
import '../../../shared/models/appointment.dart';
import '../../../shared/models/barber.dart';
import '../../../shared/models/service_model.dart';
import '../../../shared/utils/mock_data.dart';
import '../domain/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppDatabase _db;
  
  // Keep local memory cache for mock editing
  static final List<Appointment> _memAppointments = [...MockData.appointments];

  AppointmentRepositoryImpl(this._db);

  @override
  Future<List<Appointment>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      // 1. Try reading from Drift offline cache
      final cached = await _db.select(_db.cachedAppointments).get();
      if (cached.isNotEmpty) {
        return cached.map((c) {
          final srvList = (jsonDecode(c.servicesJson) as List)
              .map((s) => ServiceModel.fromJson(s as Map<String, dynamic>))
              .toList();

          return Appointment(
            id: c.id,
            userId: c.userId,
            barberId: c.barberId,
            barberName: c.barberName,
            barberAvatar: c.barberAvatar,
            services: srvList,
            date: c.date,
            time: c.time,
            totalValue: c.totalValue,
            status: c.status,
            notes: c.notes,
          );
        }).toList();
      }
    } catch (_) {
      // Silently fall back to mock
    }

    // 2. Populate Drift cache with default mock data if empty
    for (final apt in _memAppointments) {
      try {
        await _db.into(_db.cachedAppointments).insertOnConflictUpdate(
          CachedAppointmentsCompanion.insert(
            id: apt.id,
            userId: apt.userId,
            barberId: apt.barberId,
            barberName: apt.barberName,
            barberAvatar: apt.barberAvatar,
            date: apt.date,
            time: apt.time,
            totalValue: apt.totalValue,
            status: apt.status,
            servicesJson: jsonEncode(apt.services.map((s) => s.toJson()).toList()),
            notes: Value(apt.notes),
          ),
        );
      } catch (_) {}
    }

    return _memAppointments;
  }

  @override
  Future<Appointment> createAppointment(Appointment appointment) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Add to memory mock
    _memAppointments.insert(0, appointment);

    // Save to Drift offline cache
    try {
      await _db.into(_db.cachedAppointments).insertOnConflictUpdate(
        CachedAppointmentsCompanion.insert(
          id: appointment.id,
          userId: appointment.userId,
          barberId: appointment.barberId,
          barberName: appointment.barberName,
          barberAvatar: appointment.barberAvatar,
          date: appointment.date,
          time: appointment.time,
          totalValue: appointment.totalValue,
          status: appointment.status,
          servicesJson: jsonEncode(appointment.services.map((s) => s.toJson()).toList()),
          notes: Value(appointment.notes),
        ),
      );
    } catch (_) {}

    return appointment;
  }

  @override
  Future<Appointment> cancelAppointment(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final idx = _memAppointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final updated = _memAppointments[idx].copyWith(status: 'cancelled');
      _memAppointments[idx] = updated;

      // Update in Drift offline cache
      try {
        await _db.update(_db.cachedAppointments).write(
          CachedAppointmentsCompanion(
            status: Value(updated.status),
          ),
        );
      } catch (_) {}

      return updated;
    }

    throw Exception('Agendamento não encontrado');
  }

  @override
  Future<List<Barber>> getBarbers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.barbers;
  }

  @override
  Future<List<ServiceModel>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.services;
  }
}
