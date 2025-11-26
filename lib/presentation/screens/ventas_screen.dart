import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/sale_notifier.dart';
import '../../data/mock_data/mock_data.dart'; // Para obtener la lista de productos
import '../widgets/custom_app_bar.dart';

class VentasScreen extends ConsumerWidget {
  const VentasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleState = ref.watch(saleProvider);
    final saleNotifier = ref.read(saleProvider.notifier);

    // Usamos mockProducts para simular la búsqueda de productos
    final availableProducts =
        mockProducts.where((p) => p.isAvailable && p.stock > 0).toList();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Gestión de Ventas'),
      body: Column(
        children: [
          // 1. Carrito de Compras (HU_101)
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration:
                BoxDecoration(border: Border.all(color: Colors.blueGrey)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CARRITO DE VENTAS',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                if (saleState.cart.isEmpty)
                  const Text('El carrito está vacío.')
                else
                  ...saleState.cart
                      .map((item) => ListTile(
                            dense: true,
                            title: Text('${item.name} x${item.quantity}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            trailing: Text(
                                '\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                            onTap: () =>
                                saleNotifier.removeItemFromCart(item.productId),
                          ))
                      .toList(),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('TOTAL: \$${saleState.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue)),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 5),
            child: Text('PRODUCTOS DISPONIBLES',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),

          // 2. Listado de Productos (Para añadir al carrito)
          Expanded(
            child: ListView.builder(
              itemCount: availableProducts.length,
              itemBuilder: (context, index) {
                final product = availableProducts[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                      'Stock: ${product.stock} | Categoría: ${product.category}'),
                  trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                  onTap: () {
                    // HU_101: Añadir al carrito
                    saleNotifier.addItemToCart(
                        product.id, product.name, product.price);
                  },
                );
              },
            ),
          ),
        ],
      ),
      // HU_104: Botón para finalizar venta
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saleState.cart.isNotEmpty
            ? () => _showFinalizeSaleDialog(context, saleNotifier)
            : null,
        label: const Text('Finalizar Venta'),
        icon: const Icon(Icons.payment),
        backgroundColor: saleState.cart.isNotEmpty ? Colors.green : Colors.grey,
      ),
    );
  }

  void _showFinalizeSaleDialog(BuildContext context, SaleNotifier notifier) {
    // Simulación de selección de cliente (HU_103)
    final clientController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total a pagar: \$${notifier.state.total.toStringAsFixed(2)}'),
            const SizedBox(height: 15),
            TextField(
                controller: clientController,
                decoration: const InputDecoration(
                    labelText: 'Nombre del Cliente (HU_103)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (clientController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Debe especificar un cliente.')));
                return;
              }
              Navigator.pop(context);
              final result = await notifier.registerSale(clientController.text);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result)));
            },
            child: const Text('Confirmar Venta'),
          ),
        ],
      ),
    );
  }
}
