class ServiceOrderModel {
  final int id;
  final int motoId;
  final String clientName;
  final String motoPlaca;
  final String mechanicName;
  final String status; // Pendiente, En Progreso, Finalizado
  final DateTime entryDate;
  final String workDescription;

  ServiceOrderModel({
    required this.id,
    required this.motoId,
    required this.clientName,
    required this.motoPlaca,
    required this.mechanicName,
    required this.status,
    required this.entryDate,
    required this.workDescription,
  });
}
