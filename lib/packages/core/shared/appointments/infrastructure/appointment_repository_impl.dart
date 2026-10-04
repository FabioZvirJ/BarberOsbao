import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';
import 'package:barber_osbao/packages/core/storage/drift_db.dart';
import 'package:barber_osbao/packages/core/models/appointment.dart';
import 'package:barber_osbao/packages/core/models/barber.dart';
import 'package:barber_osbao/packages/core/models/branch.dart';
import 'package:barber_osbao/packages/core/models/service_model.dart';
import 'package:barber_osbao/packages/core/shared/appointments/domain/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppDatabase _db;
  final DioClient _dioClient;

  AppointmentRepositoryImpl(this._db, this._dioClient);

  @override
  Future<List<Appointment>> getAppointments({String? branchId}) async {
    try {
      final response = await _dioClient.dio.get(
        '/appointments',
        queryParameters: branchId != null ? {'branchId': branchId} : null,
      );

      final data = response.data as List;
      final appointments = <Appointment>[];

      for (final item in data) {
        final map = item as Map<String, dynamic>;
        final branchJson = map['branch'];
        if (branchJson != null && branchJson is Map<String, dynamic>) {
          final br = Branch.fromJson(branchJson);
          if (map['barberName'] != null) {
            BarberBranchRegistry.register(map['barberName'], br);
          }
        }

        final statusStr = (map['status']?.toString().toLowerCase() == 'cancelado' ||
                map['status']?.toString().toLowerCase() == 'cancelled')
            ? 'cancelled'
            : 'confirmed';

        final srvList = <ServiceModel>[];
        final serviceName = map['serviceName'] ?? map['services'] ?? 'Serviço';
        srvList.add(ServiceModel(
          id: map['id'] ?? '',
          name: serviceName,
          category: 'geral',
          price: (map['price'] as num?)?.toDouble() ?? 0.0,
          durationMinutes: 30,
          iconName: 'scissors',
          description: '',
        ));

        final apt = Appointment(
          id: map['id'] ?? '',
          userId: map['clientPhone'] ?? map['clientName'] ?? '',
          barberId: map['barberName'] ?? '',
          barberName: map['barberName'] ?? 'Barbeiro',
          barberAvatar: map['barberAvatar'] ?? '',
          services: srvList,
          date: map['date'] ?? '',
          time: map['time'] ?? '',
          totalValue: (map['price'] as num?)?.toDouble() ?? 0.0,
          status: statusStr,
          notes: map['notes'],
        );
        appointments.add(apt);

        // Update Drift offline cache
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
                  servicesJson: jsonEncode(
                    apt.services.map((s) => s.toJson()).toList(),
                  ),
                  notes: Value(apt.notes),
                ),
              );
        } catch (_) {}
      }

      return appointments;
    } catch (_) {
      // Offline fallback: try reading from Drift offline cache
      try {
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
      } catch (_) {}
      return [];
    }
  }

  @override
  Future<Appointment> createAppointment(Appointment appointment) async {
    final branch = BarberBranchRegistry.getBranch(appointment.barberId) ??
        BarberBranchRegistry.getBranch(appointment.barberName);

    try {
      final response = await _dioClient.dio.post(
        '/appointments',
        data: {
          'clientName': appointment.userId.isNotEmpty ? appointment.userId : 'Cliente',
          'barberName': appointment.barberName,
          'barberAvatar': appointment.barberAvatar,
          'serviceName': appointment.services.map((s) => s.name).join(', '),
          'date': appointment.date,
          'time': appointment.time,
          'price': appointment.totalValue,
          'status': 'Pendente',
          'notes': appointment.notes,
          'branchId': branch?.id,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final created = appointment.copyWith(id: data['id'] ?? appointment.id);

      // Save to Drift offline cache
      try {
        await _db.into(_db.cachedAppointments).insertOnConflictUpdate(
              CachedAppointmentsCompanion.insert(
                id: created.id,
                userId: created.userId,
                barberId: created.barberId,
                barberName: created.barberName,
                barberAvatar: created.barberAvatar,
                date: created.date,
                time: created.time,
                totalValue: created.totalValue,
                status: created.status,
                servicesJson: jsonEncode(
                  created.services.map((s) => s.toJson()).toList(),
                ),
                notes: Value(created.notes),
              ),
            );
      } catch (_) {}

      return created;
    } catch (_) {
      // Offline fallback: save locally
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
                servicesJson: jsonEncode(
                  appointment.services.map((s) => s.toJson()).toList(),
                ),
                notes: Value(appointment.notes),
              ),
            );
      } catch (_) {}
      return appointment;
    }
  }

  @override
  Future<Appointment> cancelAppointment(String id) async {
    try {
      await _dioClient.dio.put('/appointments/$id', data: {'status': 'Cancelado'});
    } catch (_) {
      try {
        await _dioClient.dio.delete('/appointments/$id');
      } catch (_) {}
    }

    try {
      await (_db.update(_db.cachedAppointments)
            ..where((tbl) => tbl.id.equals(id)))
          .write(const CachedAppointmentsCompanion(status: Value('cancelled')));
    } catch (_) {}

    return Appointment(
      id: id,
      userId: '',
      barberId: '',
      barberName: '',
      barberAvatar: '',
      services: [],
      date: '',
      time: '',
      totalValue: 0.0,
      status: 'cancelled',
    );
  }

  @override
  Future<List<Barber>> getBarbers({String? branchId}) async {
    try {
      final response = await _dioClient.dio.get(
        '/employees',
        queryParameters: branchId != null ? {'branchId': branchId} : null,
      );

      final data = response.data as List;
      final barbers = <Barber>[];

      for (final item in data) {
        final emp = item as Map<String, dynamic>;
        final branchJson = emp['branch'];
        if (branchJson != null && branchJson is Map<String, dynamic>) {
          final br = Branch.fromJson(branchJson);
          BarberBranchRegistry.register(emp['id'] ?? '', br);
          BarberBranchRegistry.register(emp['name'] ?? '', br);
        }

        final specs = (emp['specialties'] is List)
            ? List<String>.from(emp['specialties'])
            : <String>[];
        final days = (emp['diasDisponiveis'] is List)
            ? List<String>.from(emp['diasDisponiveis'])
            : <String>[];

        barbers.add(Barber(
          id: emp['id'] ?? '',
          name: emp['name'] ?? '',
          avatarUrl: emp['avatarUrl'] ?? '',
          rating: (emp['rating'] as num?)?.toDouble() ?? 5.0,
          specialties: specs.isNotEmpty ? specs : ['Atendimento Geral'],
          bio: emp['cargo'] ?? 'Profissional',
          availableDays: days,
          availableHours: const [
            '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00'
          ],
          commissionRate: (emp['commissionRate'] as num?)?.toDouble() ?? 0.3,
          status: emp['status'] == false ? 'inactive' : 'active',
        ));
      }

      return barbers;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<ServiceModel>> getServices({String? branchId}) async {
    try {
      final response = await _dioClient.dio.get(
        '/services',
        queryParameters: branchId != null ? {'branchId': branchId} : null,
      );

      final data = response.data as List;
      return data.map((s) {
        final sm = s as Map<String, dynamic>;
        return ServiceModel(
          id: sm['id'] ?? '',
          name: sm['name'] ?? '',
          category: sm['category']?.toString().toLowerCase() ?? 'geral',
          price: (sm['price'] as num?)?.toDouble() ?? 0.0,
          durationMinutes: (sm['durationMinutes'] as num?)?.toInt() ?? 30,
          iconName: 'scissors',
          description: sm['description'] ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
