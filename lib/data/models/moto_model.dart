class MotoModel {
  final int id;
  final int clientId; // ID del cliente dueño
  final String placa; // HU_82
  final String marca; // HU_82
  final String modelo; // HU_82
  final int anio;
  final String color;
  final String vin; // Identificación del vehículo
  final bool isActive;

  MotoModel({
    required this.id,
    required this.clientId,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.color,
    required this.vin,
    this.isActive = true,
  });
}
