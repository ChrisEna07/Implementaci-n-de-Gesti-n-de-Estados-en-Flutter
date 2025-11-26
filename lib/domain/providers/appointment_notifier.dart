import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/appointment_model.dart';
import '../../data/mock_data/mock_data.dart'; // Para Clients y Motos

// Proveedor para la lista de Agendamientos (HU_40, HU_41, HU_42)
final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, List<AppointmentModel>>((ref) {
  return AppointmentNotifier([
    AppointmentModel(
        id: 301,
        clientId: 1,
        motoId: 1,
        dateTime: DateTime.now().add(const Duration(hours: 3)),
        serviceType: 'Cambio de Aceite',
        employeeId: 'Mech1',
        isConfirmed: true),
    AppointmentModel(
        id: 302,
        clientId: 2,
        motoId: 2,
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
        serviceType: 'Revisión General',
        employeeId: 'Mech1',
        isConfirmed: false),
  ]);
});

class AppointmentNotifier extends StateNotifier<List<AppointmentModel>> {
  AppointmentNotifier(super.state);

  final List<AppointmentModel> _allAppointments = [
    AppointmentModel(
        id: 301,
        clientId: 1,
        motoId: 1,
        dateTime: DateTime.now().add(const Duration(hours: 3)),
        serviceType: 'Cambio de Aceite',
        employeeId: 'Mech1',
        isConfirmed: true),
    AppointmentModel(
        id: 302,
        clientId: 2,
        motoId: 2,
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
        serviceType: 'Revisión General',
        employeeId: 'Mech1',
        isConfirmed: false),
  ];

  String _currentSearchTerm = '';

  void searchAppointments(String term) {
    _currentSearchTerm = term.toLowerCase();
    _filterAppointments();
  }

  void _filterAppointments() {
    if (_currentSearchTerm.isEmpty) {
      state = _allAppointments;
    } else {
      state = _allAppointments
          .where((a) =>
              a.serviceType.toLowerCase().contains(_currentSearchTerm) ||
              a.dateTime.toString().contains(_currentSearchTerm))
          .toList();
    }
  }

  // --- Operaciones CRUD ---

  Future<String> registerAppointment(int clientId, int motoId,
      DateTime dateTime, String serviceType, String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newId =
        _allAppointments.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1;
    final newAppointment = AppointmentModel(
        id: newId,
        clientId: clientId,
        motoId: motoId,
        dateTime: dateTime,
        serviceType: serviceType,
        employeeId: employeeId);
    _allAppointments.add(newAppointment);
    _filterAppointments();
    return 'Agendamiento para ${serviceType} registrado el ${dateTime.toString().substring(0, 16)}.';
  }

  Future<String> editAppointment(AppointmentModel original, DateTime dateTime,
      String serviceType, String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _allAppointments.indexWhere((a) => a.id == original.id);
    if (index == -1) return 'Error: Agendamiento no encontrado.';

    _allAppointments[index] = original.copyWith(
      dateTime: dateTime,
      serviceType: serviceType,
      employeeId: employeeId,
    );
    _filterAppointments();
    return 'Agendamiento #${original.id} actualizado con éxito.';
  }

  Future<String> toggleConfirmation(
      AppointmentModel appointment, bool isConfirmed) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _allAppointments.indexWhere((a) => a.id == appointment.id);
    if (index == -1) return 'Error: Agendamiento no encontrado.';

    _allAppointments[index] = appointment.copyWith(isConfirmed: isConfirmed);
    _filterAppointments();
    return 'Agendamiento #${appointment.id} ${isConfirmed ? 'Confirmado' : 'Pendiente'}.';
  }
}
