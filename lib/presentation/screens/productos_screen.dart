import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/product_list_notifier.dart';
import '../../data/mock_data/mock_data.dart';
import '../widgets/custom_app_bar.dart';

class ProductosScreen extends ConsumerWidget {
  const ProductosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha el estado del ProductListNotifier
    final productState = ref.watch(productListProvider);
    final productNotifier = ref.read(productListProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Gestión de Productos'),
      body: Column(
        children: [
          // Sección de Filtros y Ordenamiento
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Filtro por Categoría (simula CU20)
                DropdownButton<String>(
                  value: productState.currentFilter,
                  items: ['Todos', ...mockCategories].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      productNotifier.loadProducts(filterCategory: newValue);
                    }
                  },
                ),
                // Ordenar por (simula CU20)
                DropdownButton<String>(
                  value: productState.currentSort,
                  items: const [
                    DropdownMenuItem(value: 'Ninguno', child: Text('Ordenar')),
                    DropdownMenuItem(value: 'name', child: Text('Nombre A-Z')),
                    DropdownMenuItem(
                        value: 'price_asc', child: Text('Precio Asc.')),
                  ],
                  onChanged: (newValue) {
                    if (newValue != null) {
                      productNotifier.loadProducts(sortBy: newValue);
                    }
                  },
                ),
              ],
            ),
          ),

          // Listado de Productos (CU19 Listar productos)
          Expanded(
            child: productState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productState.products.isEmpty
                    ? const Center(
                        child: Text(
                            'No se encontraron productos disponibles.')) // CA_41_02
                    : ListView.builder(
                        itemCount: productState.products.length,
                        itemBuilder: (context, index) {
                          final product = productState.products[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                                'Categoría: ${product.category} | Stock: ${product.stock}'),
                            trailing:
                                Text('\$${product.price.toStringAsFixed(2)}'),
                            onTap: () {
                              // Navegación a CU23 Ver detalle de un producto
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Simulando Ver Detalle del Producto...')),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Acción para CU18 Registrar productos
        },
        label: const Text('Nuevo Producto'),
        icon: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}
