import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/auth_notifier.dart';
// Importa todas las pantallas
import 'agendamientos_screen.dart';
import 'categorias_productos_screen.dart';
import 'clientes_screen.dart';
import 'compras_screen.dart';
import 'horarios_screen.dart';
import 'motos_screen.dart';
import 'pedidos_servicios_screen.dart';
import 'productos_screen.dart';
import 'proveedores_screen.dart';
import 'roles_screen.dart';
import 'usuarios_screen.dart';
import 'ventas_screen.dart';

// Lista de módulos con una 'key' única y la pantalla a mostrar
final List<Map<String, dynamic>> modules = [
  {
    'key': 'dashboard',
    'title': 'Dashboard',
    'icon': Icons.dashboard,
    'screen': const _DashboardContent()
  },
  {
    'key': 'clientes',
    'title': 'Clientes',
    'icon': Icons.person,
    'screen': const ClientesScreen()
  },
  {
    'key': 'motos',
    'title': 'Motos',
    'icon': Icons.two_wheeler,
    'screen': const MotosScreen()
  },
  {
    'key': 'ventas',
    'title': 'Ventas',
    'icon': Icons.monetization_on,
    'screen': const VentasScreen()
  },
  {
    'key': 'pedidos',
    'title': 'Pedidos Servicios',
    'icon': Icons.build,
    'screen': const PedidosServiciosScreen()
  },
  {
    'key': 'productos',
    'title': 'Productos',
    'icon': Icons.category,
    'screen': const ProductosScreen()
  },
  {
    'key': 'categorias',
    'title': 'Categorías',
    'icon': Icons.label,
    'screen': const CategoriasProductosScreen()
  },
  {
    'key': 'compras',
    'title': 'Compras',
    'icon': Icons.shopping_cart,
    'screen': const ComprasScreen()
  },
  {
    'key': 'proveedores',
    'title': 'Proveedores',
    'icon': Icons.local_shipping,
    'screen': const ProveedoresScreen()
  },
  {
    'key': 'usuarios',
    'title': 'Usuarios',
    'icon': Icons.people,
    'screen': const UsuariosScreen()
  },
  {
    'key': 'roles',
    'title': 'Roles',
    'icon': Icons.security,
    'screen': const RolesScreen()
  },
  {
    'key': 'horarios',
    'title': 'Horarios',
    'icon': Icons.access_time,
    'screen': const HorariosScreen()
  },
  {
    'key': 'agendamientos',
    'title': 'Agendamientos',
    'icon': Icons.calendar_month,
    'screen': const AgendamientosScreen()
  },
];

// StateProvider que almacena la clave (key) de la pantalla actual.
final currentScreenKeyProvider = StateProvider<String>((ref) => 'dashboard');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final authNotifier = ref.read(authProvider.notifier);

    // 1. Obtener la clave de la pantalla actual (observamos el cambio)
    final currentKey = ref.watch(currentScreenKeyProvider);

    // 2. Encontrar el módulo activo (contiene el título y el widget)
    final currentModule = modules.firstWhere(
      (m) => m['key'] == currentKey,
      orElse: () =>
          modules.first, // Si la clave no existe, muestra el Dashboard
    );

    // 3. Extraer Título y Widget
    final currentTitle = currentModule['title'] as String;
    final currentScreen = currentModule['screen'] as Widget;

    return Scaffold(
      // 4. El AppBar usa el título dinámico
      appBar: AppBar(
        title: Text(currentTitle),
        backgroundColor: Colors.blue.shade700,
        actions: [
          // Muestra el Rol del usuario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(child: Text('Rol: ${user?.role ?? 'N/A'}')),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authNotifier.logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Header del Drawer
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Usuario'),
              accountEmail: Text(user?.email ?? 'Panel Administrativo'),
              currentAccountPicture:
                  const CircleAvatar(child: Icon(Icons.verified_user)),
              decoration: BoxDecoration(color: Colors.blue.shade700),
            ),

            // --- Listado de Módulos (Sección de Navegación) ---
            ...modules
                .map((module) => ListTile(
                      // Usar 'selected' para destacar la opción activa
                      selected: module['key'] == currentKey,
                      leading: Icon(module['icon'] as IconData),
                      title: Text(module['title']),
                      onTap: () {
                        // Actualiza el proveedor de estado con la clave del nuevo módulo
                        ref.read(currentScreenKeyProvider.notifier).state =
                            module['key'] as String;
                        Navigator.pop(context); // Cierra el drawer
                      },
                    ))
                .toList(),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.red)),
              onTap: authNotifier.logout,
            ),
          ],
        ),
      ),

      // 5. El Body muestra la pantalla dinámica seleccionada
      body: currentScreen,
    );
  }
}

// Placeholder para el contenido del Dashboard
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Bienvenido al Dashboard. Usa el menú lateral para navegar por los módulos.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
