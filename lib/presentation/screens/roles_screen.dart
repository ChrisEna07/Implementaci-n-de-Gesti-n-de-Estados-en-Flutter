import 'package:flutter/material.dart';

// --- Modelos de Datos de Ejemplo ---
class Role {
  final int id;
  final String name;
  final String description;
  final int userCount;
  final bool isActive;

  Role({
    required this.id,
    required this.name,
    required this.description,
    required this.userCount,
    required this.isActive,
  });
}

final List<Role> mockRoles = [
  Role(
      id: 1,
      name: 'Administrador',
      description: 'Acceso total al sistema y configuración.',
      userCount: 2,
      isActive: true),
  Role(
      id: 2,
      name: 'Mecánico',
      description: 'Gestión de motos, servicios y pedidos.',
      userCount: 5,
      isActive: true),
  Role(
      id: 3,
      name: 'Cliente',
      description: 'Visualización de sus motos y pedidos de servicio.',
      userCount: 25,
      isActive: true),
  Role(
      id: 4,
      name: 'Vendedor',
      description: 'Gestión de ventas y compras.',
      userCount: 1,
      isActive: false),
];

// --- Roles Screen ---
class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  String _searchQuery = '';
  List<Role> _filteredRoles = mockRoles;

  @override
  void initState() {
    super.initState();
    _filterRoles();
  }

  void _filterRoles() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredRoles = mockRoles;
      } else {
        _filteredRoles = mockRoles
            .where((role) =>
                role.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                role.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  // CORRECCIÓN: Cambiar la firma de la función para que acepte un parámetro Role
  void _showRoleFormDialog([Role? role]) {
    // Implementar la lógica para agregar o editar un rol
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(role == null ? 'Nuevo Rol' : 'Editar Rol: ${role.name}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Aquí irían los campos del formulario para el rol
                TextFormField(
                  initialValue: role?.name,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del Rol'),
                ),
                TextFormField(
                  initialValue: role?.description,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                // Más campos como permisos, etc.
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
              child: Text(role == null ? 'Crear Rol' : 'Guardar Cambios'),
              onPressed: () {
                // Lógica de guardado (simulada)
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          '${role == null ? 'Rol Creado' : 'Rol Actualizado'} exitosamente.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Roles'),
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
                      labelText: 'Buscar Roles...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterRoles();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showRoleFormDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Rol'),
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
                        header: const Text('Listado de Roles'),
                        rowsPerPage: 5,
                        columns: const [
                          DataColumn(label: Text('Rol')),
                          DataColumn(label: Text('Descripción')),
                          DataColumn(label: Text('Usuarios')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        source: _RoleDataSource(
                            _filteredRoles, context, _showRoleFormDialog),
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
class _RoleDataSource extends DataTableSource {
  final List<Role> roles;
  final BuildContext context;
  final Function(Role?) onEdit;

  _RoleDataSource(this.roles, this.context, this.onEdit);

  @override
  DataRow? getRow(int index) {
    if (index >= roles.length) return null;
    final role = roles[index];

    return DataRow(cells: [
      DataCell(Text(role.name)),
      DataCell(SizedBox(
          width: 250,
          child: Text(role.description, overflow: TextOverflow.ellipsis))),
      DataCell(Text(role.userCount.toString())),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: role.isActive
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role.isActive ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: role.isActive ? Colors.green[800] : Colors.red[800],
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
              onPressed: () => onEdit(role),
              tooltip: 'Editar Rol',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Implementar lógica de eliminación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Eliminando rol ${role.name}...')),
                );
              },
              tooltip: 'Eliminar Rol',
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => roles.length;

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
      home: const RolesScreen(),
    );
  }
}
