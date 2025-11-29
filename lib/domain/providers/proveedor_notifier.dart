import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/proveedor_model.dart';
// Asumo que mockData existe

// Proveedor para la lista de proveedores (similar a clientProvider)
final proveedorProvider =
    StateNotifierProvider<ProveedorNotifier, List<ProveedorModel>>((ref) {
  // Inicializamos con los datos ficticios
  return ProveedorNotifier([
    ProveedorModel(
        id: 101,
        nombre: 'Repuestos Rueda S.A.',
        contacto: 'Juan Pérez',
        telefono: '555-1001',
        email: 'rueda@repuestos.com',
        direccion: 'Calle 1'),
    ProveedorModel(
        id: 102,
        nombre: 'Aceites Motorizados Ltda.',
        contacto: 'Ana Gómez',
        telefono: '555-1002',
        email: 'motor@aceites.com',
        direccion: 'Avenida 2'),
  ]);
});

class ProveedorNotifier extends StateNotifier<List<ProveedorModel>> {
  ProveedorNotifier(super.state);

  // Variable para la búsqueda
  String _currentSearchTerm = '';

  // Lógica de búsqueda
  void searchProveedores(String term) {
    _currentSearchTerm = term.toLowerCase();
    _filterProveedores();
  }

  // Aplica el filtro a la lista original (asumiendo que mockProveedores existe)
  void _filterProveedores() {
    if (_currentSearchTerm.isEmpty) {
      state = _allProveedores;
    } else {
      state = _allProveedores
          .where((p) =>
              p.nombre.toLowerCase().contains(_currentSearchTerm) ||
              p.contacto.toLowerCase().contains(_currentSearchTerm) ||
              p.telefono.contains(_currentSearchTerm))
          .toList();
    }
  }

  // --- Operaciones CRUD (HU_95: Registro, HU_97: Edición, HU_98: Inactivar) ---

  // Simulación de todos los proveedores disponibles
  List<ProveedorModel> get _allProveedores => [
        ProveedorModel(
            id: 101,
            nombre: 'Repuestos Rueda S.A.',
            contacto: 'Juan Pérez',
            telefono: '555-1001',
            email: 'rueda@repuestos.com',
            direccion: 'Calle 1',
            isActive: true),
        ProveedorModel(
            id: 102,
            nombre: 'Aceites Motorizados Ltda.',
            contacto: 'Ana Gómez',
            telefono: '555-1002',
            email: 'motor@aceites.com',
            direccion: 'Avenida 2',
            isActive: true),
        ProveedorModel(
            id: 103,
            nombre: 'Llantas Seguras',
            contacto: 'Carlos V.',
            telefono: '555-1003',
            email: 'seguras@llantas.com',
            direccion: 'Carrera 3',
            isActive: false),
      ];

  Future<String> registerProveedor(String nombre, String contacto,
      String telefono, String email, String direccion) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula latencia
    final newId =
        _allProveedores.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    final newProveedor = ProveedorModel(
        id: newId,
        nombre: nombre,
        contacto: contacto,
        telefono: telefono,
        email: email,
        direccion: direccion);
    _allProveedores.add(newProveedor);
    _filterProveedores(); // Refresca la vista
    return 'Proveedor $nombre registrado con éxito.';
  }

  Future<String> editProveedor(ProveedorModel original, String nombre,
      String contacto, String telefono, String direccion) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _allProveedores.indexWhere((p) => p.id == original.id);
    if (index == -1) return 'Error: Proveedor no encontrado.';

    _allProveedores[index] = original.copyWith(
      nombre: nombre,
      contacto: contacto,
      telefono: telefono,
      direccion: direccion,
    );
    _filterProveedores();
    return 'Proveedor $nombre actualizado con éxito.';
  }

  Future<String> toggleStatus(ProveedorModel proveedor, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _allProveedores.indexWhere((p) => p.id == proveedor.id);
    if (index == -1) return 'Error: Proveedor no encontrado.';

    _allProveedores[index] = proveedor.copyWith(isActive: isActive);
    _filterProveedores();
    return 'Proveedor ${proveedor.nombre} ${isActive ? 'activado' : 'inactivado'} con éxito.';
  }
}
