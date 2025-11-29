import 'package:flutter/material.dart';

// --- Modelos de Datos de Ejemplo ---
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isEnabled,
  });
}

final List<User> mockUsers = [
  User(
      id: 101,
      name: 'Juan Pérez',
      email: 'juan.perez@admin.com',
      role: 'Administrador',
      isEnabled: true),
  User(
      id: 102,
      name: 'María García',
      email: 'maria.g@mecanico.com',
      role: 'Mecánico',
      isEnabled: true),
  User(
      id: 103,
      name: 'Carlos López',
      email: 'carlos.l@mecanico.com',
      role: 'Mecánico',
      isEnabled: true),
  User(
      id: 104,
      name: 'Ana Rojas',
      email: 'ana.r@cliente.com',
      role: 'Cliente',
      isEnabled: false),
  User(
      id: 105,
      name: 'Pedro Torres',
      email: 'pedro.t@cliente.com',
      role: 'Cliente',
      isEnabled: true),
  User(
      id: 106,
      name: 'Elena Soto',
      email: 'elena.s@admin.com',
      role: 'Administrador',
      isEnabled: true),
];

// --- Usuarios Screen ---
class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  String _searchQuery = '';
  List<User> _filteredUsers = mockUsers;

  @override
  void initState() {
    super.initState();
    _filterUsers();
  }

  void _filterUsers() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredUsers = mockUsers;
      } else {
        _filteredUsers = mockUsers
            .where((user) =>
                user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.role.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  // CORRECCIÓN: Cambiar parámetro nombrado a posicional opcional
  void _showUserFormDialog([User? user]) {
    // Implementar la lógica para agregar o editar un usuario
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              user == null ? 'Nuevo Usuario' : 'Editar Usuario: ${user.name}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Aquí irían los campos del formulario para el usuario
                TextFormField(
                  initialValue: user?.name,
                  decoration:
                      const InputDecoration(labelText: 'Nombre Completo'),
                ),
                TextFormField(
                  initialValue: user?.email,
                  decoration:
                      const InputDecoration(labelText: 'Correo Electrónico'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: user?.role ?? 'Cliente',
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: ['Administrador', 'Mecánico', 'Cliente', 'Vendedor']
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: (value) {},
                ),
                // Más campos como contraseña, teléfono, etc.
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(user == null ? 'Crear Usuario' : 'Guardar Cambios'),
              onPressed: () {
                // Lógica de guardado (simulada)
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          '${user == null ? 'Usuario Creado' : 'Usuario Actualizado'} exitosamente.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Lógica para cambiar el estado (activar/desactivar)
  void _toggleUserStatus(User user) {
    setState(() {
      // En una aplicación real, aquí harías una llamada a la API para cambiar el estado.
      // Simulando el cambio de estado en la lista de mockUsers:
      final index = mockUsers.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        mockUsers[index] = User(
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          isEnabled: !user.isEnabled,
        );
        _filterUsers(); // Refiltrar la lista
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Estado de ${user.name} cambiado a ${user.isEnabled ? 'Inactivo' : 'Activo'}.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar Usuarios por nombre, email o rol...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterUsers();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showUserFormDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Usuario'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      PaginatedDataTable(
                        header: const Text('Listado de Usuarios'),
                        rowsPerPage: 5,
                        columns: const [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Rol')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        source: _UserDataSource(_filteredUsers, context,
                            _showUserFormDialog, _toggleUserStatus),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Fuente de Datos para la Tabla ---
class _UserDataSource extends DataTableSource {
  final List<User> users;
  final BuildContext context;
  final Function(User?) onEdit;
  final Function(User) onToggleStatus;

  _UserDataSource(this.users, this.context, this.onEdit, this.onToggleStatus);

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];

    return DataRow(cells: [
      DataCell(Text(user.name)),
      DataCell(Text(user.email)),
      DataCell(Text(user.role)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: user.isEnabled
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.isEnabled ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: user.isEnabled ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(user),
              tooltip: 'Editar Usuario',
            ),
            IconButton(
              icon: Icon(user.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                  color: user.isEnabled ? Colors.green : Colors.grey),
              onPressed: () => onToggleStatus(user),
              tooltip:
                  user.isEnabled ? 'Desactivar Usuario' : 'Activar Usuario',
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}

// --- Widget para Previsualización (Opcional, solo para que el archivo sea ejecutable en un entorno de prueba) ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rafa Motos Admin',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const UsuariosScreen(),
    );
  }
}
