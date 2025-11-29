import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/purchase_model.dart';
// Para Proveedores

// Proveedor para la lista de Compras (HU_100)
final purchaseProvider =
    StateNotifierProvider<PurchaseNotifier, List<PurchaseModel>>((ref) {
  return PurchaseNotifier([
    PurchaseModel(
        id: 201,
        proveedorId: 101,
        date: DateTime.now().subtract(const Duration(days: 7)),
        isCompleted: true,
        items: [
          PurchaseItemModel(
              itemName: 'Filtro de aceite', quantity: 20, unitCost: 5.50)
        ]),
    PurchaseModel(
        id: 202,
        proveedorId: 102,
        date: DateTime.now().subtract(const Duration(days: 3)),
        isCompleted: false,
        items: [
          PurchaseItemModel(
              itemName: 'Aceite sintético 10W40', quantity: 100, unitCost: 8.00)
        ]),
  ]);
});

class PurchaseNotifier extends StateNotifier<List<PurchaseModel>> {
  PurchaseNotifier(super.state);

  // Lista simulada de todas las compras
  final List<PurchaseModel> _allPurchases = [
    PurchaseModel(
        id: 201,
        proveedorId: 101,
        date: DateTime.now().subtract(const Duration(days: 7)),
        isCompleted: true,
        items: [
          PurchaseItemModel(
              itemName: 'Filtro de aceite', quantity: 20, unitCost: 5.50)
        ]),
    PurchaseModel(
        id: 202,
        proveedorId: 102,
        date: DateTime.now().subtract(const Duration(days: 3)),
        isCompleted: false,
        items: [
          PurchaseItemModel(
              itemName: 'Aceite sintético 10W40', quantity: 100, unitCost: 8.00)
        ]),
  ];

  String _currentSearchTerm = '';

  void searchPurchases(String term) {
    _currentSearchTerm = term.toLowerCase();
    _filterPurchases();
  }

  void _filterPurchases() {
    // La lógica de búsqueda podría ser compleja (por ítem, por proveedor, por ID)
    if (_currentSearchTerm.isEmpty) {
      state = _allPurchases;
    } else {
      state = _allPurchases
          .where((p) =>
              p.id.toString().contains(_currentSearchTerm) ||
              p.items.any((item) =>
                  item.itemName.toLowerCase().contains(_currentSearchTerm)) ||
              p.totalAmount.toStringAsFixed(2).contains(_currentSearchTerm))
          .toList();
    }
  }

  // --- Operaciones CRUD (HU_100: Registrar, HU_102: Marcar como completa) ---

  Future<String> registerPurchase(
      int proveedorId, List<PurchaseItemModel> items) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newId =
        _allPurchases.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    final newPurchase = PurchaseModel(
      id: newId,
      proveedorId: proveedorId,
      date: DateTime.now(),
      items: items,
      isCompleted: false,
    );
    _allPurchases.add(newPurchase);
    _filterPurchases();
    return 'Orden de Compra #$newId registrada con éxito. Total: \$${newPurchase.totalAmount.toStringAsFixed(2)}';
  }

  Future<String> markAsCompleted(PurchaseModel purchase) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _allPurchases.indexWhere((p) => p.id == purchase.id);
    if (index == -1) return 'Error: Compra no encontrada.';

    _allPurchases[index] = purchase.copyWith(isCompleted: true);
    _filterPurchases();
    return 'Orden de Compra #${purchase.id} marcada como completada y los ítems añadidos al inventario (simulación).';
  }
}
