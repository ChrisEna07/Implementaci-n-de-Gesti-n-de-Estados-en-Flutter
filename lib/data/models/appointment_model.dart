class AppointmentModel {
  final int id;
  final int clientId;
  final int motoId;
  final DateTime dateTime;
  final String serviceType;
  final String employeeId; // ID del empleado asignado (si aplica)
  final bool isConfirmed;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.motoId,
    required this.dateTime,
    required this.serviceType,
    required this.employeeId,
    this.isConfirmed = false,
  });

  AppointmentModel copyWith({
    int? id,
    int? clientId,
    int? motoId,
    DateTime? dateTime,
    String? serviceType,
    String? employeeId,
    bool? isConfirmed,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      motoId: motoId ?? this.motoId,
      dateTime: dateTime ?? this.dateTime,
      serviceType: serviceType ?? this.serviceType,
      employeeId: employeeId ?? this.employeeId,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}
