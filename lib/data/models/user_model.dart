class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // 'Administrador', 'Mecánico', 'Cliente'
  final String telefono; // VARCHAR(20)
  final String token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.telefono,
    required this.token,
  });

  // Constructor para usuario no autenticado
  const UserModel.unauthenticated()
      : id = 0,
        name = '',
        email = '',
        role = '',
        telefono = '',
        token = '';

  // MÉTODO COPYWITH - ESENCIAL PARA RIVERPOD
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? telefono,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      telefono: telefono ?? this.telefono,
      token: token ?? this.token,
    );
  }

  // Método toMap para serialización
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'telefono': telefono,
      'token': token,
    };
  }

  // Método fromMap para deserialización
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      telefono: map['telefono'] ?? '',
      token: map['token'] ?? '',
    );
  }

  // Métodos de igualdad
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.telefono == telefono &&
        other.token == token;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, role, telefono, token);
  }

  // Método toString para debugging
  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, telefono: $telefono, token: ${token.isNotEmpty ? '***' : 'empty'})';
  }

  // Métodos de utilidad
  bool get isAuthenticated => token.isNotEmpty;
  bool get isAdmin => role == 'Administrador';
  bool get isMecanico => role == 'Mecánico';
  bool get isCliente => role == 'Cliente';
  bool get isEmpty => id == 0 && name.isEmpty && email.isEmpty;
}
