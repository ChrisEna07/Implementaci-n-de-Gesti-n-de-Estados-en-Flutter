import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importaciones de tu dominio y datos
import '../../domain/providers/sale_notifier.dart';
import '../../data/mock_data/mock_data.dart';
import '../widgets/custom_app_bar.dart';

class VentasScreen extends ConsumerWidget {
  const VentasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ---------------------------------------------------------
    // 1. OBTENCIÓN DE ESTADO Y LÓGICA (RIVERPOD)
    // ---------------------------------------------------------

    // ref.watch: Escucha cambios. Si el estado del carrito cambia,
    // Flutter reconstruye (repinta) toda esta pantalla automáticamente.
    final saleState = ref.watch(saleProvider);

    // ref.read: Solo lee. Lo usamos para acceder a las funciones (métodos)
    // del Notifier (agregar, quitar, finalizar) sin provocar repintados innecesarios.
    final saleNotifier = ref.read(saleProvider.notifier);

    // Filtramos los productos que tienen stock > 0 y están disponibles
    final availableProducts =
        mockProducts.where((p) => p.isAvailable && p.stock > 0).toList();

    return Scaffold(
      // Usamos tu AppBar personalizada
      appBar: const CustomAppBar(title: 'Gestión de Ventas'),

      body: Column(
        children: [
          // -------------------------------------------------------
          // 2. SECCIÓN DEL CARRITO DE COMPRAS (HU_101)
          // -------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey), // Borde visual
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del carrito
                const Text('CARRITO DE VENTAS',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),

                // Lógica visual: Si está vacío mostramos mensaje, si no, la lista.
                if (saleState.cart.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: Text('El carrito está vacío.')),
                  )
                else
                  // 'Spread operator' (...) para insertar la lista de widgets aquí
                  ...saleState.cart.map((item) => ListTile(
                        dense: true, // Hace el item más compacto
                        title: Text('${item.name} x${item.quantity}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        // Cálculo del subtotal por item
                        trailing: Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                        // Al tocar, eliminamos el item del carrito
                        onTap: () =>
                            saleNotifier.removeItemFromCart(item.productId),
                      )),

                const Divider(),

                // Muestra el TOTAL acumulado de la venta
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

          // Título separador
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 5),
            child: Text('PRODUCTOS DISPONIBLES',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),

          // -------------------------------------------------------
          // 3. LISTADO DE PRODUCTOS DISPONIBLES
          // -------------------------------------------------------
          // Expanded obliga a la lista a ocupar todo el espacio restante de la pantalla
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
                    // Acción: Agregar producto al carrito
                    saleNotifier.addItemToCart(
                        product.id, product.name, product.price);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // -------------------------------------------------------
      // 4. BOTÓN FLOTANTE PARA FINALIZAR (HU_104)
      // -------------------------------------------------------
      floatingActionButton: FloatingActionButton.extended(
        // Deshabilitamos el botón (null) si el carrito está vacío
        onPressed: saleState.cart.isNotEmpty
            ? () => _showFinalizeSaleDialog(context, saleNotifier)
            : null,
        label: const Text('Finalizar Venta'),
        icon: const Icon(Icons.payment),
        // Cambia de color si está habilitado o no
        backgroundColor: saleState.cart.isNotEmpty ? Colors.green : Colors.grey,
      ),
    );
  }

  // -------------------------------------------------------
  // 5. LÓGICA DEL DIÁLOGO Y CORRECCIÓN DEL ERROR
  // -------------------------------------------------------
  void _showFinalizeSaleDialog(BuildContext context, SaleNotifier notifier) {
    // Controlador para capturar el texto del input
    final clientController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Finalizar Venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min, // El diálogo se ajusta al contenido
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
          // Botón Cancelar: Cierra el diálogo sin hacer nada
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar')),

          // Botón Confirmar: Aquí estaba el problema, ahora corregido.
          ElevatedButton(
            onPressed: () async {
              // Validación simple
              if (clientController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(
                    content: Text('Debe especificar un cliente.')));
                return;
              }

              // ==============================================================
              // CORRECCIÓN DEL ERROR "Deactivated widget's ancestor"
              // ==============================================================

              // PASO 1: Guardamos una referencia al ScaffoldMessenger *AHORA*
              // que el contexto (dialogContext) todavía es válido y existe.
              final messenger = ScaffoldMessenger.of(dialogContext);

              // PASO 2: Cerramos el diálogo.
              // En este momento, 'dialogContext' deja de ser válido visualmente.
              Navigator.pop(dialogContext);

              // PASO 3: Ejecutamos la operación asíncrona (await).
              // Esto toma tiempo. Mientras tanto, el diálogo ya se cerró.
              final result = await notifier.registerSale(clientController.text);

              // PASO 4: Usamos la variable 'messenger' que guardamos en el Paso 1.
              // Ya NO usamos 'ScaffoldMessenger.of(context)' aquí, porque fallaría.
              messenger.showSnackBar(SnackBar(content: Text(result)));

              // ==============================================================
            },
            child: const Text('Confirmar Venta'),
          ),
        ],
      ),
    );
  }
}
