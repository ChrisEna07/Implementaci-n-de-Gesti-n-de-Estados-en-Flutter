// Este Notifier gestiona empleados, roles y horarios (HU_1, HU_2, HU_3, HU_4, HU_5)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart'; // Usamos UserModel para empleados
import '../../data/mock_data/mock_data.dart'; // Asumo que mockUsers existe
import '../../data/mock_data/mock_roles_schedules.dart'; // Roles y Horarios

// Notifier para la lista de EMPLEADOS
final employeeProvider =
    StateNotifierProvider<EmployeeNotifier, List<UserModel>>((ref) {
  // Inicializamos con los usuarios que NO son 'Cliente'
  final initialEmployees = mockUsers.where((u) => u.role != 'Cliente').toList();
  return EmployeeNotifier(initialEmployees);
});

// Notifier para ROLES y HORARIOS disponibles (simplificado como un simple Provider)
final roleScheduleProvider = Provider((ref) => {
      'roles': availableRoles,
      'schedules': availableSchedules,
    });

class EmployeeNotifier extends StateNotifier<List<UserModel>> {
  EmployeeNotifier(super.initialState);

  String _currentSearchTerm = '';

  // Simulación de todos los empleados
  List<UserModel> get _allEmployees =>
      mockUsers.where((u) => u.role != 'Cliente').toList();

  void searchEmployees(String term) {
    _currentSearchTerm = term.toLowerCase();
    _filterEmployees();
  }

  void _filterEmployees() {
    if (_currentSearchTerm.isEmpty) {
      state = _allEmployees;
    } else {
      state = _allEmployees
          .where((u) =>
              u.name.toLowerCase().contains(_currentSearchTerm) ||
              u.email.toLowerCase().contains(_currentSearchTerm) ||
              u.role.toLowerCase().contains(_currentSearchTerm))
          .toList();
    }
  }

  // --- Operaciones CRUD Empleados ---

  Future<String> registerEmployee(
    String name,
    String email,
    String role,
    String telefono,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Asignar un ID ficticio para el nuevo empleado
    final newId = mockUsers.isNotEmpty
        ? mockUsers.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1
        : 1;

    final newEmployee = UserModel(
      id: newId,
      name: name,
      email: email,
      telefono: telefono,
      role: role,
      token: '', // Token vacío para empleados nuevos
    );

    mockUsers.add(newEmployee); // Lo añadimos al mock global
    _filterEmployees(); // Actualizamos el estado
    return 'Empleado $name registrado como $role con éxito.';
  }

  Future<String> editEmployee(
    UserModel original,
    String name,
    String role,
    String telefono,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _allEmployees.indexWhere((u) => u.id == original.id);
    if (index == -1) return 'Error: Empleado no encontrado.';

    final updatedEmployee = original.copyWith(
      name: name,
      role: role,
      telefono: telefono,
    );

    // Actualizar en el mock global (si fuera real, sería en la base de datos)
    final globalIndex = mockUsers.indexWhere((u) => u.id == original.id);
    if (globalIndex != -1) {
      mockUsers[globalIndex] = updatedEmployee;
    }

    _filterEmployees(); // Actualizamos el estado
    return 'Empleado $name actualizado con éxito.';
  }

  Future<String> toggleStatus(UserModel employee, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // En este mock, solo simulamos la eliminación
    final globalIndex = mockUsers.indexWhere((u) => u.id == employee.id);
    if (globalIndex != -1) {
      mockUsers.removeAt(globalIndex);
    }

    _filterEmployees(); // Actualizamos el estado
    return 'Empleado ${employee.name} ${isActive ? 'activado' : 'inactivado'} con éxito.';
  }

  // Método adicional para obtener empleado por ID
  UserModel? getEmployeeById(int id) {
    try {
      return _allEmployees.firstWhere((employee) => employee.id == id);
    } catch (e) {
      return null;
    }
  }

  // Método para recargar empleados
  void reloadEmployees() {
    _filterEmployees();
  }
}
