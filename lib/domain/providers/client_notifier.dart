import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/mock_data/mock_data.dart'; // Importa mockUsers

// El estado será una lista de UserModel filtrados por rol Cliente
final clientProvider =
    StateNotifierProvider<ClientNotifier, List<UserModel>>((ref) {
  // Inicializamos con solo los usuarios que tienen el rol 'Cliente'
  final initialClients = mockUsers.where((u) => u.role == 'Cliente').toList();
  return ClientNotifier(initialClients);
});

class ClientNotifier extends StateNotifier<List<UserModel>> {
  ClientNotifier(super.initialClients);

  // Genera un ID mock simple para nuevos clientes
  int _getNextId() {
    // Busca el ID más alto entre todos los mockUsers para evitar colisiones.
    if (mockUsers.isEmpty) return 1;
    return mockUsers.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // Helper: Obtener el nombre del cliente por ID (Usado en MotoNotifier)
  String getClientName(int clientId) {
    return mockUsers
        .firstWhere((u) => u.id == clientId,
            orElse: () => const UserModel(
                id: 0,
                name: 'Desconocido',
                email: '',
                role: 'Cliente',
                telefono: '',
                token: ''))
        .name;
  }

  // HU_68: Registrar un nuevo cliente
  Future<String> registerClient(String name, String email, String phone) async {
    // CA_68_02: Validar que el email no exista en la base de datos de usuarios
    if (mockUsers.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      return 'Error: Ya existe un usuario (cliente o empleado) con este correo electrónico.';
    }

    // Simulación de latencia de la base de datos
    await Future.delayed(const Duration(milliseconds: 50));

    final newClient = UserModel(
      id: _getNextId(),
      name: name,
      email: email,
      role: 'Cliente', // El rol siempre es Cliente
      telefono: phone,
      token: 'token_cli_${_getNextId()}',
    );

    // 1. Agregar al estado local del Notifier
    state = [...state, newClient];
    // 2. También agregar al mock global para simular la persistencia y evitar colisiones futuras
    mockUsers.add(newClient);

    // CA_68_03: Mensaje de éxito
    return 'Cliente "$name" registrado exitosamente.';
  }

  // HU_75: Editar la información de un cliente
  Future<String> editClient(
      UserModel client, String newName, String newPhone) async {
    // Simulación de latencia
    await Future.delayed(const Duration(milliseconds: 50));

    final updatedClient = UserModel(
      id: client.id,
      name: newName, // Se edita
      email: client.email, // No se edita
      role: client.role,
      telefono: newPhone, // Se edita
      token: client.token,
    );

    // 1. Actualizar el estado local
    state = state.map((c) => c.id == client.id ? updatedClient : c).toList();

    // 2. Actualizar también la lista global mockUsers (simulando persistencia en DB)
    int index = mockUsers.indexWhere((u) => u.id == client.id);
    if (index != -1) {
      mockUsers[index] = updatedClient;
    }

    // CA_75_03: Mensaje de éxito
    return 'Información del cliente actualizada exitosamente.';
  }

  // HU_77: Eliminar un cliente
  Future<String> deleteClient(int id) async {
    final clientToDelete = state.firstWhere((c) => c.id == id);

    // Aquí iría la lógica de verificación (si tiene motos/ventas asociadas)

    await Future.delayed(const Duration(milliseconds: 50));

    // 1. Eliminar del estado local
    state = state.where((c) => c.id != id).toList();
    // 2. Eliminar del mock global
    mockUsers.removeWhere((u) => u.id == id);

    // CA_77_04: Mensaje de éxito
    return 'Cliente "${clientToDelete.name}" eliminado correctamente.';
  }

  // HU_66: Buscar cliente por nombre/email/teléfono
  void searchClients(String query) {
    // 1. Siempre obtenemos la lista completa de clientes (del mock global)
    final allClients = mockUsers.where((u) => u.role == 'Cliente').toList();

    if (query.isEmpty) {
      // Si la búsqueda está vacía, mostrar todos los clientes iniciales
      state = allClients;
      return;
    }

    final lowerQuery = query.toLowerCase();

    // 2. Filtrar basado en la query
    final filteredClients = allClients
        .where((u) =>
            u.name.toLowerCase().contains(lowerQuery) ||
            u.email.toLowerCase().contains(lowerQuery) ||
            u.telefono.contains(lowerQuery))
        .toList();

    state = filteredClients;
  }
}
