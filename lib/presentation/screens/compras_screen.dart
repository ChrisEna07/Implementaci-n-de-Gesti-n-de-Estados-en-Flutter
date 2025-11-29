import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/purchase_model.dart';
import '../../data/models/proveedor_model.dart';
import '../../domain/providers/purchase_notifier.dart';
import '../../domain/providers/proveedor_notifier.dart';
import '../widgets/custom_app_bar.dart';

class ComprasScreen extends ConsumerWidget {
  const ComprasScreen({super.key});

  void _showPurchaseForm(BuildContext context, PurchaseNotifier pNotifier,
      List<ProveedorModel> proveedores) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: _PurchaseForm(
            purchaseNotifier: pNotifier,
            proveedores: proveedores,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = ref.watch(purchaseProvider);
    final purchaseNotifier = ref.read(purchaseProvider.notifier);
    final proveedores = ref.watch(proveedorProvider);

    void showFormHandler() {
      _showPurchaseForm(context, purchaseNotifier,
          proveedores.where((p) => p.isActive).toList());
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gestión de Compras',
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: showFormHandler,
            tooltip: 'Registrar Nueva Orden de Compra',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: purchaseNotifier.searchPurchases,
              decoration: const InputDecoration(
                labelText: 'Buscar Compra (ID, Ítem, Total)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ),
          Expanded(
            child: purchases.isEmpty
                ? const Center(
                    child: Text('No se encontraron órdenes de compra.'))
                : ListView.builder(
                    itemCount: purchases.length,
                    itemBuilder: (context, index) {
                      final purchase = purchases[index];
                      final proveedor = ref.watch(proveedorProvider).firstWhere(
                          (p) => p.id == purchase.proveedorId,
                          orElse: () => ProveedorModel(
                              id: -1,
                              nombre: 'Desconocido',
                              contacto: '',
                              telefono: '',
                              email: '',
                              direccion: ''));
                      return _PurchaseListItem(
                        purchase: purchase,
                        proveedorName: proveedor.nombre,
                        purchaseNotifier: purchaseNotifier,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseListItem extends StatelessWidget {
  final PurchaseModel purchase;
  final String proveedorName;
  final PurchaseNotifier purchaseNotifier;

  const _PurchaseListItem({
    required this.purchase,
    required this.proveedorName,
    required this.purchaseNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 3,
      color:
          purchase.isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
      child: ListTile(
        leading: Icon(
            purchase.isCompleted ? Icons.check_circle : Icons.pending_actions,
            color: purchase.isCompleted
                ? Colors.green.shade700
                : Colors.orange.shade700),
        title: Text('Compra #${purchase.id} - $proveedorName',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Fecha: ${purchase.date.toString().substring(0, 10)}\nTotal: \$${purchase.totalAmount.toStringAsFixed(2)} - ${purchase.items.length} ítems.'),
        isThreeLine: true,
        trailing: purchase.isCompleted
            ? const Text('COMPLETADA',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
            : IconButton(
                icon: const Icon(Icons.done_all, color: Colors.blue),
                onPressed: () async {
                  final result =
                      await purchaseNotifier.markAsCompleted(purchase);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(result)));
                },
                tooltip: 'Marcar como completada',
              ),
      ),
    );
  }
}

class _PurchaseForm extends StatefulWidget {
  final PurchaseNotifier purchaseNotifier;
  final List<ProveedorModel> proveedores;

  const _PurchaseForm(
      {required this.purchaseNotifier, required this.proveedores});

  @override
  State<_PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends State<_PurchaseForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedProveedorId;
  final List<PurchaseItemModel> _items = [];
  bool _isLoading = false;

  void _addItem() {
    setState(() {
      _items.add(PurchaseItemModel(itemName: '', quantity: 0, unitCost: 0.0));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  // CORRECCIÓN: Método para actualizar items sin copyWith
  void _updateItemName(int index, String value) {
    setState(() {
      _items[index] = PurchaseItemModel(
        itemName: value,
        quantity: _items[index].quantity,
        unitCost: _items[index].unitCost,
      );
    });
  }

  void _updateItemQuantity(int index, String value) {
    final quantity = int.tryParse(value) ?? 0;
    setState(() {
      _items[index] = PurchaseItemModel(
        itemName: _items[index].itemName,
        quantity: quantity,
        unitCost: _items[index].unitCost,
      );
    });
  }

  void _updateItemUnitCost(int index, String value) {
    final unitCost = double.tryParse(value) ?? 0.0;
    setState(() {
      _items[index] = PurchaseItemModel(
        itemName: _items[index].itemName,
        quantity: _items[index].quantity,
        unitCost: unitCost,
      );
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe añadir al menos un ítem.')));
      return;
    }

    // Validar que todos los items tengan nombre
    for (var item in _items) {
      if (item.itemName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Todos los ítems deben tener nombre.')));
        return;
      }
    }

    setState(() => _isLoading = true);

    String resultMessage = await widget.purchaseNotifier
        .registerPurchase(_selectedProveedorId!, _items);

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(resultMessage)));

    if (!resultMessage.startsWith('Error')) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registrar Nueva Compra (HU_100)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Selector de Proveedor
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Proveedor'),
              items: widget.proveedores
                  .map((p) =>
                      DropdownMenuItem(value: p.id, child: Text(p.nombre)))
                  .toList(),
              onChanged: (newValue) =>
                  setState(() => _selectedProveedorId = newValue),
              validator: (value) =>
                  value == null ? 'Seleccione un proveedor' : null,
            ),
            const SizedBox(height: 20),

            // Lista de Ítems
            Text('Ítems de la Compra:',
                style: Theme.of(context).textTheme.titleMedium),
            ..._items.asMap().entries.map((entry) {
              int index = entry.key;
              PurchaseItemModel item = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        initialValue: item.itemName,
                        decoration:
                            InputDecoration(labelText: 'Ítem ${index + 1}'),
                        validator: (v) =>
                            v!.isEmpty ? 'Nombre requerido' : null,
                        onChanged: (v) => _updateItemName(index, v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: item.quantity.toString(),
                        decoration: const InputDecoration(labelText: 'Cant.'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty || int.tryParse(v) == null
                            ? 'Inválido'
                            : null,
                        onChanged: (v) => _updateItemQuantity(index, v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: item.unitCost.toString(),
                        decoration:
                            const InputDecoration(labelText: 'Costo U.'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v!.isEmpty || double.tryParse(v) == null
                                ? 'Inválido'
                                : null,
                        onChanged: (v) => _updateItemUnitCost(index, v),
                      ),
                    ),
                    IconButton(
                        icon:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeItem(index)),
                  ],
                ),
              );
            }),

            TextButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Añadir Ítem'),
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrar Orden de Compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
