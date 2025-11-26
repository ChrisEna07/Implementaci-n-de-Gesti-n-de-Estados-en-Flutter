import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/category_notifier.dart';
import '../../data/models/category_model.dart';
import '../widgets/custom_app_bar.dart';

class CategoriasProductosScreen extends ConsumerWidget {
  const CategoriasProductosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // HU_40: Listar categorías de producto
    final categories = ref.watch(categoryProvider);
    final notifier = ref.read(categoryProvider.notifier);

    // CA_40_01: La tabla deberá cargar en menos de 400 ms.
    // (Simulado en la carga inicial al crear el notifier)

    return Scaffold(
      appBar: const CustomAppBar(title: 'Gestión de Categorías'),
      body: categories.isEmpty
          ? const Center(child: Text('No hay categorías registradas.'))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.name),
                  subtitle: Text(category.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // HU_42: Cambiar estado
                      Switch(
                        value: category.isActive,
                        onChanged: (newValue) async {
                          final result = await notifier.toggleStatus(
                              category.id, newValue);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(result)));
                        },
                      ),
                      // HU_43: Editar
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showEditDialog(context, notifier, category),
                      ),
                      // HU_44: Eliminar
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(context, notifier, category),
                      ),
                    ],
                  ),
                  onTap: () {
                    // HU_45: Ver detalle
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Detalle de ${category.name}')),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegisterDialog(context, notifier),
        label: const Text('Nueva Categoría'),
        icon: const Icon(Icons.label),
      ),
    );
  }

  // Diálogo para Registrar (HU_39)
  void _showRegisterDialog(BuildContext context, CategoryNotifier notifier) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre (Requerido)')),
            TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre es obligatorio.')));
                return;
              }
              Navigator.pop(context);
              final result = await notifier.registerCategory(
                  nameController.text, descController.text);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result)));
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  // Diálogo para Editar (HU_43)
  void _showEditDialog(
      BuildContext context, CategoryNotifier notifier, CategoryModel category) {
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(text: category.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              Navigator.pop(context);
              final result = await notifier.editCategory(
                  category.id, nameController.text, descController.text);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result)));
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Diálogo para Confirmar Eliminación (HU_44)
  void _confirmDelete(
      BuildContext context, CategoryNotifier notifier, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        // CA_44_02: Mensaje de alerta antes de eliminar
        content:
            Text('¿Está seguro de eliminar la categoría "${category.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await notifier.deleteCategory(category.id);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result)));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
