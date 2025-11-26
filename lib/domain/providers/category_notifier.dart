import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/mock_data/mock_data.dart'; // Contiene mockCategoriesData y mockProducts

// Definición del StateNotifier
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  return CategoryNotifier(ref);
});

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final Ref ref;
  CategoryNotifier(this.ref) : super(mockCategoriesData);

  // Genera un ID mock simple
  // Aseguramos que la lista no esté vacía antes de reducir, si es el caso, empezamos en 1
  int _getNextId() {
    if (state.isEmpty) return 1;
    return state.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // HU_39: Registrar una categoría
  Future<String> registerCategory(String name, String description) async {
    // CA_39_02: Validar que no existan categorías con el mismo nombre antes de registrar
    if (state.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      return 'Error: Ya existe una categoría con ese nombre.';
    }

    await Future.delayed(
        const Duration(milliseconds: 50)); // Simular respuesta rápida

    final newCategory = CategoryModel(
      id: _getNextId(),
      name: name,
      description: description,
      isActive: true,
    );

    state = [...state, newCategory];
    // CA_39_03: Mensaje de éxito en menos de 500 ms
    return 'Categoría registrada exitosamente.';
  }

  // HU_43: Editar una categoría
  Future<String> editCategory(
      int id, String newName, String newDescription) async {
    // La variable 'originalCategory' fue ELIMINADA ya que no se usaba.

    // CA_43_02: Validar que no exista otra categoría activa con el mismo nombre
    if (state.any((c) =>
        c.id != id &&
        c.name.toLowerCase() == newName.toLowerCase() &&
        c.isActive)) {
      return 'Error: Ya existe una categoría activa con ese nombre.';
    }

    await Future.delayed(const Duration(milliseconds: 50));

    state = state.map((c) {
      if (c.id == id) {
        // CA_43_01: Permite editar Nombre y Descripción
        return CategoryModel(
            id: id,
            name: newName,
            description: newDescription,
            isActive: c.isActive);
      }
      return c;
    }).toList();

    // CA_43_03: Mensaje de éxito en menos de 500 ms
    return 'Categoría actualizada exitosamente en menos de 500 ms.';
  }

  // HU_42: Cambiar estado de una categoría
  Future<String> toggleStatus(int id, bool newStatus) async {
    final categoryToToggle = state.firstWhere((c) => c.id == id);

    // Regla de Negocio (CA_42_02): Si se intenta desactivar una categoría en uso, se bloquea.
    if (!newStatus && _isCategoryUsed(categoryToToggle.name)) {
      return 'Error: No es posible desactivar esta categoría porque está en uso por un producto.';
    }

    await Future.delayed(const Duration(milliseconds: 50));

    state = state.map((c) {
      return c.id == id
          ? CategoryModel(
              id: id,
              name: c.name,
              description: c.description,
              isActive: newStatus)
          : c;
    }).toList();

    // CA_42_03: Mensaje de estado actualizado correctamente.
    return 'Estado actualizado correctamente.';
  }

  // HU_44: Eliminar una categoría
  Future<String> deleteCategory(int id) async {
    final categoryName = state.firstWhere((c) => c.id == id).name;

    // CA_44_01: Solo se podrán eliminar categorías que no estén asociadas a ningún producto
    if (_isCategoryUsed(categoryName)) {
      // CA_44_03: Mensaje de error si está en uso.
      return 'Error: No es posible eliminar esta categoría porque está en uso.';
    }

    await Future.delayed(const Duration(milliseconds: 50));

    state = state.where((c) => c.id != id).toList();

    // CA_44_04: Mensaje de éxito.
    return 'Categoría eliminada correctamente.';
  }

  // Helper: Verifica si la categoría está en uso por algún producto
  bool _isCategoryUsed(String categoryName) {
    // Usamos 'mockProducts' que está importado desde 'mock_data.dart'
    return mockProducts.any((p) => p.category == categoryName);
  }
}
