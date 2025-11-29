import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_data/mock_data.dart';
import '../../data/models/service_order_model.dart';

final serviceOrderProvider =
    StateNotifierProvider<ServiceOrderNotifier, List<ServiceOrderModel>>((ref) {
  return ServiceOrderNotifier();
});

class ServiceOrderNotifier extends StateNotifier<List<ServiceOrderModel>> {
  ServiceOrderNotifier() : super(mockServiceOrders); // HU_118: Listar órdenes

  // HU_123: Actualizar Estado
  Future<String> updateStatus(int id, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 50));

    state = state.map((order) {
      if (order.id == id) {
        return ServiceOrderModel(
          id: order.id,
          motoId: order.motoId,
          clientName: order.clientName,
          motoPlaca: order.motoPlaca,
          mechanicName: order.mechanicName,
          status: newStatus, // Actualiza el estado
          entryDate: order.entryDate,
          workDescription: order.workDescription,
        );
      }
      return order;
    }).toList();

    return 'Estado de la orden #$id actualizado a "$newStatus".';
  }
}
