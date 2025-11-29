import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/mock_data/mock_data.dart'; // Importamos los datos mock

// Estado para manejar la lista de productos
class ProductListState {
  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final String currentFilter; // Categoría seleccionada
  final String currentSort; // Criterio de ordenamiento

  ProductListState({
    required this.products,
    this.isLoading = false,
    this.error,
    this.currentFilter = 'Todos',
    this.currentSort = 'Ninguno',
  });
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier();
});

class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier() : super(ProductListState(products: [])) {
    loadProducts();
  }

  // Carga, filtra y ordena los productos
  Future<void> loadProducts({String? filterCategory, String? sortBy}) async {
    state = ProductListState(
      products: state.products,
      isLoading: true,
      currentFilter: filterCategory ?? state.currentFilter,
      currentSort: sortBy ?? state.currentSort,
    );

    await Future.delayed(
        const Duration(milliseconds: 400)); // Simular CA_40_01 (Carga en 400ms)

    // 1. Aplicar Filtro (CU20 Buscar productos/Filtro por categoría)
    List<ProductModel> filtered =
        mockProducts.where((p) => p.isAvailable).toList(); // Solo disponibles
    if (state.currentFilter != 'Todos') {
      filtered =
          filtered.where((p) => p.category == state.currentFilter).toList();
    }

    // 2. Aplicar Ordenamiento
    if (state.currentSort == 'name') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (state.currentSort == 'price_asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    }

    state = ProductListState(
      products: filtered,
      isLoading: false,
      currentFilter: state.currentFilter,
      currentSort: state.currentSort,
    );
  }
}
