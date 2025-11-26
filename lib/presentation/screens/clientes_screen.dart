import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../domain/providers/client_notifier.dart';
import '../widgets/custom_app_bar.dart';

class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  // Muestra el modal para registrar o editar un cliente
  void _showClientForm(BuildContext context, ClientNotifier notifier,
      {UserModel? clientToEdit}) {
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
          child: _ClientForm(
            clientNotifier: notifier,
            clientToEdit: clientToEdit,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Observa la lista de clientes
    final clients = ref.watch(clientProvider);
    final clientNotifier = ref.read(clientProvider.notifier);

    return Scaffold(
      // Usamos el CustomAppBar con un botón de acción
      appBar: CustomAppBar(
        title: 'Gestión de Clientes',
        actions: [
          // HU_68: Botón para añadir un nuevo cliente
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showClientForm(context, clientNotifier),
            tooltip: 'Agregar Nuevo Cliente',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: clientNotifier
                  .searchClients, // HU_66: Búsqueda por nombre/email/teléfono
              decoration: const InputDecoration(
                labelText: 'Buscar Cliente (Nombre, Email, Teléfono)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ),
          Expanded(
            child: clients.isEmpty
                ? const Center(child: Text('No se encontraron clientes.'))
                : ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return _ClientListItem(
                        client: client,
                        clientNotifier: clientNotifier,
                        onEdit: () => _showClientForm(
                          context,
                          clientNotifier,
                          clientToEdit: client,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Widget del formulario separado para manejar la lógica de estado y validación
class _ClientForm extends StatefulWidget {
  final ClientNotifier clientNotifier;
  final UserModel? clientToEdit;

  const _ClientForm({required this.clientNotifier, this.clientToEdit});

  @override
  State<_ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<_ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _phone;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializar campos si se está editando
    _name = widget.clientToEdit?.name ?? '';
    _email = widget.clientToEdit?.email ?? '';
    _phone = widget.clientToEdit?.telefono ?? '';
  }

  // Función principal de envío de formulario
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    String resultMessage;

    if (widget.clientToEdit == null) {
      // Registrar nuevo cliente (HU_68)
      resultMessage =
          await widget.clientNotifier.registerClient(_name, _email, _phone);
    } else {
      // Editar cliente existente (HU_75)
      resultMessage = await widget.clientNotifier
          .editClient(widget.clientToEdit!, _name, _phone);
    }

    // --- CORRECCIÓN DE ERROR 2: BuildContext across async gaps ---
    // Usar 'mounted' para verificar que el widget sigue en el árbol
    // antes de usar el 'context' (ej. Navigator.pop, ScaffoldMessenger).
    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultMessage,
            style: TextStyle(
              color: resultMessage.startsWith('Error')
                  ? Colors.red.shade900
                  : Colors.white,
            )),
        backgroundColor: resultMessage.startsWith('Error')
            ? Colors.red.shade100
            : Colors.green,
      ),
    );

    if (!resultMessage.startsWith('Error')) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.clientToEdit == null
                ? 'Registrar Nuevo Cliente'
                : 'Editar Cliente: ${widget.clientToEdit!.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          TextFormField(
            initialValue: _name,
            decoration:
                const InputDecoration(labelText: 'Nombre Completo (HU_75)'),
            validator: (value) => value!.isEmpty ? 'Ingrese un nombre' : null,
            onSaved: (value) => _name = value!,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 10),

          // El email solo se permite editar si es un nuevo registro
          TextFormField(
            initialValue: _email,
            decoration: const InputDecoration(labelText: 'Email (HU_68)'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value!.isEmpty ? 'Ingrese un email válido' : null,
            onSaved: (value) => _email = value!,
            enabled: widget.clientToEdit == null &&
                !_isLoading, // Desactivar edición de email
          ),
          const SizedBox(height: 10),

          TextFormField(
            initialValue: _phone,
            decoration: const InputDecoration(labelText: 'Teléfono (HU_68)'),
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? 'Ingrese un teléfono' : null,
            onSaved: (value) => _phone = value!,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 20),

          Center(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.clientToEdit == null
                      ? 'Registrar Cliente'
                      : 'Guardar Cambios'),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar cada cliente en la lista
class _ClientListItem extends ConsumerWidget {
  final UserModel client;
  final ClientNotifier clientNotifier;
  final VoidCallback onEdit;

  const _ClientListItem({
    required this.client,
    required this.clientNotifier,
    required this.onEdit,
  });

  // Muestra el modal de confirmación para eliminar (HU_77)
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
            '¿Está seguro de que desea eliminar al cliente ${client.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Cierra el diálogo de confirmación
              final result = await clientNotifier.deleteClient(client.id);

              // Evitamos el error de BuildContext usando el if (!mounted) return;
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 3,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(client.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${client.email}'),
            Text('Teléfono: ${client.telefono}'),
            Text('ID: ${client.id}',
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HU_75: Botón de Editar
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Editar Cliente',
            ),
            // HU_77: Botón de Eliminar
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
              tooltip: 'Eliminar Cliente',
            ),
          ],
        ),
        onTap: () {
          // Lógica para ver detalles o historial
        },
      ),
    );
  }
}
