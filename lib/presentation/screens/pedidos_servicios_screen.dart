import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/service_order_notifier.dart';
import '../../data/models/service_order_model.dart';
import '../widgets/custom_app_bar.dart';

class PedidosServiciosScreen extends ConsumerWidget {
  const PedidosServiciosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(serviceOrderProvider);
    final notifier = ref.read(serviceOrderProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Pedidos de Servicio'),
      body: orders.isEmpty
          ? const Center(child: Text('No hay órdenes de servicio registradas.'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final statusColor = _getStatusColor(order.status);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor,
                    child: Text('${order.id}',
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(
                      'Placa: ${order.motoPlaca} | Cliente: ${order.clientName}'),
                  subtitle: Text(
                      'Mecánico: ${order.mechanicName}\nDescripción: ${order.workDescription}'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(order.status,
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => _showStatusDialog(
                      context, notifier, order), // HU_123: Cambiar estado
                );
              },
            ),
      // HU_119: Botón para Registrar
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Simulando registrar nueva orden (HU_119)...')));
        },
        label: const Text('Nueva Orden'),
        icon: const Icon(Icons.receipt_long),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.orange;
      case 'En Progreso':
        return Colors.blue;
      case 'Finalizado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showStatusDialog(BuildContext context, ServiceOrderNotifier notifier,
      ServiceOrderModel order) {
    String? newStatus = order.status;
    final List<String> statuses = ['Pendiente', 'En Progreso', 'Finalizado'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar Estado de Orden #${order.id}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButton<String>(
              value: newStatus,
              items: statuses.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  newStatus = newValue;
                });
              },
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (newStatus != null) {
                Navigator.pop(context);
                final result =
                    await notifier.updateStatus(order.id, newStatus!);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(result)));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
