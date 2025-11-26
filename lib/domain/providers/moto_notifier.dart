import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/moto_model.dart';
import '../../data/models/user_model.dart';
import '../../data/mock_data/mock_data.dart';

// El estado será una lista de MotoModel
final motoProvider =
    StateNotifierProvider<MotoNotifier, List<MotoModel>>((ref) {
  return MotoNotifier();
});

class MotoNotifier extends StateNotifier<List<MotoModel>> {
  MotoNotifier()
      : super(mockMotos
            .where((m) => m.isActive)
            .toList()); // Inicialmente solo activas

  // Genera un ID mock simple
  int _getNextId() {
    if (mockMotos.isEmpty) return 1;
    return mockMotos.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // Helper: Obtener el nombre del cliente por ID
  String _getClientName(int clientId) {
    return mockUsers
        .firstWhere((u) => u.id == clientId,
            orElse: () => UserModel(
                id: 0,
                name: 'Desconocido',
                email: '',
                role: 'Cliente',
                telefono: '',
                token: ''))
        .name;
  }

  // HU_82: Registrar una moto
  Future<String> registerMoto(int clientId, String placa, String marca,
      String modelo, int anio, String color, String vin) async {
    // CA_82_02: Validar que no exista otra moto con la misma placa
    if (mockMotos.any((m) => m.placa.toLowerCase() == placa.toLowerCase())) {
      return 'Error: Ya existe una moto registrada con la placa "$placa".';
    }

    await Future.delayed(const Duration(milliseconds: 50));

    final newMoto = MotoModel(
      id: _getNextId(),
      clientId: clientId,
      placa: placa,
      marca: marca,
      modelo: modelo,
      anio: anio,
      color: color,
      vin: vin,
      isActive: true,
    );

    mockMotos.add(newMoto);
    // Recargar la lista activa (ya que isActive es true por defecto)
    state = mockMotos.where((m) => m.isActive).toList();

    // CA_82_03: Mensaje de éxito
    return 'Moto con placa "$placa" registrada exitosamente al cliente ${_getClientName(clientId)}.';
  }

  // HU_92: Editar la información de la moto
  Future<String> editMoto(MotoModel moto, String newMarca, String newModelo,
      int newAnio, String newColor) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final updatedMoto = MotoModel(
      id: moto.id,
      clientId: moto.clientId,
      placa: moto.placa, // La placa no se edita
      marca: newMarca,
      modelo: newModelo,
      anio: newAnio,
      color: newColor,
      vin: moto.vin,
      isActive: moto.isActive,
    );

    // Actualizar el mock global y el estado local
    final index = mockMotos.indexWhere((m) => m.id == moto.id);
    if (index != -1) {
      mockMotos[index] = updatedMoto;
    }
    state = state.map((m) => m.id == moto.id ? updatedMoto : m).toList();

    return 'Moto ${moto.placa} actualizada correctamente.';
  }

  // HU_90: Cambiar estado (Activar/Inactivar)
  Future<String> toggleStatus(MotoModel moto, bool newStatus) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final updatedMoto = MotoModel(
      id: moto.id,
      clientId: moto.clientId,
      placa: moto.placa,
      marca: moto.marca,
      modelo: moto.modelo,
      anio: moto.anio,
      color: moto.color,
      vin: moto.vin,
      isActive: newStatus,
    );

    // Actualizar el mock global
    final index = mockMotos.indexWhere((m) => m.id == moto.id);
    if (index != -1) {
      mockMotos[index] = updatedMoto;
    }

    // Filtrar el estado local para solo mostrar activas (Regla de negocio implícita)
    state = mockMotos.where((m) => m.isActive).toList();

    return 'Estado de la moto ${moto.placa} cambiado a ${newStatus ? 'Activa' : 'Inactiva'}.';
  }

  // HU_83: Buscar motos por placa o VIN
  void searchMotos(String query) {
    if (query.isEmpty) {
      state = mockMotos.where((m) => m.isActive).toList();
      return;
    }

    final lowerQuery = query.toLowerCase();

    final filteredMotos = mockMotos
        .where((m) =>
            m.isActive &&
            (m.placa.toLowerCase().contains(lowerQuery) ||
                m.vin.toLowerCase().contains(lowerQuery)))
        .toList();

    state = filteredMotos;
  }

  // MÉTODO NUEVO: Obtener moto por ID (para AgendamientosScreen)
  MotoModel? getMoto(int motoId) {
    try {
      return state.firstWhere((moto) => moto.id == motoId);
    } catch (e) {
      return null;
    }
  }

  // MÉTODO ADICIONAL: Obtener motos por cliente ID
  List<MotoModel> getMotosByClientId(int clientId) {
    return state.where((moto) => moto.clientId == clientId).toList();
  }

  // MÉTODO ADICIONAL: Recargar motos
  void reloadMotos() {
    state = mockMotos.where((m) => m.isActive).toList();
  }
}
