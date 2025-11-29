import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/moto_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/providers/moto_notifier.dart';
import '../../domain/providers/client_notifier.dart'; // Necesitamos el Notifier de Cliente
import '../../data/mock_data/mock_data.dart'; // Importamos mockUsers para el listado
import '../widgets/custom_app_bar.dart';

class MotosScreen extends ConsumerWidget {
  const MotosScreen({super.key});

  // Lista de clientes para el dropdown (solo los que tienen rol 'Cliente')
  List<UserModel> get _clients =>
      mockUsers.where((u) => u.role == 'Cliente').toList();

  // Muestra el modal para registrar o editar una moto
  void _showMotoForm(BuildContext context, MotoNotifier notifier,
      ClientNotifier clientNotifier,
      {MotoModel? motoToEdit}) {
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
          child: _MotoForm(
            motoNotifier: notifier,
            motoToEdit: motoToEdit,
            clients: _clients,
            clientNotifier: clientNotifier,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observadores
    final motos = ref.watch(motoProvider);
    final motoNotifier = ref.read(motoProvider.notifier);
    final clientNotifier = ref.read(clientProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gestión de Motocicletas',
        actions: [
          // HU_82: Botón para añadir una nueva moto
          IconButton(
            icon: const Icon(Icons.add_road),
            onPressed: () =>
                _showMotoForm(context, motoNotifier, clientNotifier),
            tooltip: 'Registrar Nueva Moto',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged:
                  motoNotifier.searchMotos, // HU_83: Búsqueda por placa o VIN
              decoration: const InputDecoration(
                labelText: 'Buscar Moto (Placa o VIN)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
          ),
          Expanded(
            child: motos.isEmpty
                ? const Center(child: Text('No se encontraron motos activas.'))
                : ListView.builder(
                    itemCount: motos.length,
                    itemBuilder: (context, index) {
                      final moto = motos[index];
                      // Pasamos el Notifier de Cliente para obtener el nombre
                      return _MotoListItem(
                          moto: moto,
                          motoNotifier: motoNotifier,
                          clientNotifier: clientNotifier);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar cada moto en la lista
class _MotoListItem extends StatelessWidget {
  final MotoModel moto;
  final MotoNotifier motoNotifier;
  final ClientNotifier clientNotifier;

  const _MotoListItem(
      {required this.moto,
      required this.motoNotifier,
      required this.clientNotifier});

  @override
  Widget build(BuildContext context) {
    final clientName = clientNotifier.getClientName(moto.clientId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 3,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.two_wheeler)),
        title: Text('${moto.marca} ${moto.modelo} (${moto.placa})',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dueño: $clientName'),
            Text('Año: ${moto.anio} | Color: ${moto.color}'),
            Text('VIN: ${moto.vin}',
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        onTap: () {
          // Abrir formulario para editar (HU_92)
          final parentState =
              context.findAncestorWidgetOfExactType<MotosScreen>();
          if (parentState != null) {
            parentState._showMotoForm(context, motoNotifier, clientNotifier,
                motoToEdit: moto);
          }
        },
      ),
    );
  }
}

// Widget del formulario separado para manejar la lógica de estado y validación
class _MotoForm extends StatefulWidget {
  final MotoNotifier motoNotifier;
  final ClientNotifier clientNotifier;
  final MotoModel? motoToEdit;
  final List<UserModel> clients;

  const _MotoForm({
    required this.motoNotifier,
    required this.motoToEdit,
    required this.clients,
    required this.clientNotifier,
  });

  @override
  State<_MotoForm> createState() => _MotoFormState();
}

class _MotoFormState extends State<_MotoForm> {
  final _formKey = GlobalKey<FormState>();
  late String _placa;
  late String _marca;
  late String _modelo;
  late int _anio;
  late String _color;
  late String _vin;
  late int? _selectedClientId; // Usado solo en registro
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializar campos
    _placa = widget.motoToEdit?.placa ?? '';
    _marca = widget.motoToEdit?.marca ?? '';
    _modelo = widget.motoToEdit?.modelo ?? '';
    _anio = widget.motoToEdit?.anio ?? DateTime.now().year;
    _color = widget.motoToEdit?.color ?? '';
    _vin = widget.motoToEdit?.vin ?? '';
    _selectedClientId = widget.motoToEdit?.clientId;
  }

  // Función principal de envío de formulario
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    String resultMessage;

    if (widget.motoToEdit == null) {
      // Registrar nueva moto (HU_82)
      if (_selectedClientId == null) {
        resultMessage = 'Error: Debe seleccionar un cliente dueño.';
      } else {
        resultMessage = await widget.motoNotifier.registerMoto(
            _selectedClientId!, _placa, _marca, _modelo, _anio, _color, _vin);
      }
    } else {
      // Editar moto existente (HU_92)
      resultMessage = await widget.motoNotifier
          .editMoto(widget.motoToEdit!, _marca, _modelo, _anio, _color);
    }

    // --- CORRECCIÓN DE ERROR 2: BuildContext across async gaps ---
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.motoToEdit == null
                  ? 'Registrar Nueva Motocicleta'
                  : 'Editar Moto: ${widget.motoToEdit!.placa}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Campo de Selección de Cliente (Solo en Registro)
            if (widget.motoToEdit == null) ...[
              DropdownButtonFormField<int>(
                initialValue: _selectedClientId,
                decoration: const InputDecoration(labelText: 'Cliente Dueño'),
                items: widget.clients.map((client) {
                  return DropdownMenuItem<int>(
                    value: client.id,
                    child: Text('${client.name} (${client.telefono})'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedClientId = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione un cliente' : null,
              ),
              const SizedBox(height: 10),
            ] else ...[
              // Si es edición, muestra el cliente actual sin poder cambiarlo
              Text(
                  'Dueño Actual: ${widget.clientNotifier.getClientName(widget.motoToEdit!.clientId)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
            ],

            // Placa (Solo en Registro)
            TextFormField(
              initialValue: _placa,
              decoration: InputDecoration(
                labelText:
                    'Placa (HU_82) ${widget.motoToEdit != null ? '(No editable)' : ''}',
                enabled: widget.motoToEdit == null && !_isLoading,
              ),
              validator: (value) => value!.isEmpty ? 'Ingrese la placa' : null,
              onSaved: (value) => _placa = value!,
            ),
            const SizedBox(height: 10),

            // Marca (Editable - HU_92)
            TextFormField(
              initialValue: _marca,
              decoration: const InputDecoration(labelText: 'Marca'),
              validator: (value) => value!.isEmpty ? 'Ingrese la marca' : null,
              onSaved: (value) => _marca = value!,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            // Modelo (Editable - HU_92)
            TextFormField(
              initialValue: _modelo,
              decoration: const InputDecoration(labelText: 'Modelo'),
              validator: (value) => value!.isEmpty ? 'Ingrese el modelo' : null,
              onSaved: (value) => _modelo = value!,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            // Año (Editable - HU_92)
            TextFormField(
              initialValue: _anio.toString(),
              decoration: const InputDecoration(labelText: 'Año'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null) {
                  return 'Ingrese un año válido';
                }
                return null;
              },
              onSaved: (value) => _anio = int.parse(value!),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            // Color (Editable - HU_92)
            TextFormField(
              initialValue: _color,
              decoration: const InputDecoration(labelText: 'Color'),
              validator: (value) => value!.isEmpty ? 'Ingrese el color' : null,
              onSaved: (value) => _color = value!,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),

            // VIN (Solo en Registro)
            TextFormField(
              initialValue: _vin,
              decoration: InputDecoration(
                labelText:
                    'VIN (Identificación) ${widget.motoToEdit != null ? '(No editable)' : ''}',
                enabled: widget.motoToEdit == null && !_isLoading,
              ),
              validator: (value) => value!.isEmpty ? 'Ingrese el VIN' : null,
              onSaved: (value) => _vin = value!,
            ),
            const SizedBox(height: 30),

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
                    : Text(widget.motoToEdit == null
                        ? 'Registrar Moto'
                        : 'Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
