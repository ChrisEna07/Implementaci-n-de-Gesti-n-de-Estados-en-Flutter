class ProveedorModel {
  final int id;
  final String nombre;
  final String contacto;
  final String telefono;
  final String email;
  final String direccion;
  final bool isActive;

  ProveedorModel({
    required this.id,
    required this.nombre,
    required this.contacto,
    required this.telefono,
    required this.email,
    required this.direccion,
    this.isActive = true,
  });

  ProveedorModel copyWith({
    int? id,
    String? nombre,
    String? contacto,
    String? telefono,
    String? email,
    String? direccion,
    bool? isActive,
  }) {
    return ProveedorModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      contacto: contacto ?? this.contacto,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      direccion: direccion ?? this.direccion,
      isActive: isActive ?? this.isActive,
    );
  }
}
