import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/auth_notifier.dart';

// Importación de pantallas
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

// Lista de módulos (igual que tu original)
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

Widget _fullWidth(BoxConstraints constraints, Widget child) {
  return SizedBox(
    width: constraints.maxWidth, // 🔥 Aquí se estira al ancho total
    child: child,
  );
}

// StateProvider para clave de pantalla actual
final currentScreenKeyProvider = StateProvider<String>((ref) => 'dashboard');

// Helper: devuelve las keys permitidas según rol (sin tocar módulos)
List<String> _allowedKeysForRole(String? role) {
  if (role == null) return [];

  final r = role.toLowerCase();
  if (r == 'administrador' || r == 'admin') {
    // Admin ve todo
    return modules.map((m) => m['key'] as String).toList();
  } else if (r == 'mecánico' ||
      r == 'mecanico' ||
      r == 'mecánico'.toLowerCase()) {
    // Mecánico ve todo excepto 'proveedores','roles','dashboard'
    return modules
        .where((m) => !['proveedores', 'roles', 'dashboard'].contains(m['key']))
        .map((m) => m['key'] as String)
        .toList();
  } else if (r == 'cliente') {
    // Cliente ve sólo estas pantallas
    return ['agendamientos', 'motos', 'ventas', 'pedidos'];
  } else {
    // Por defecto vacío (no logueado)
    return [];
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final authNotifier = ref.read(authProvider.notifier);

    // Pantalla actual
    final currentKey = ref.watch(currentScreenKeyProvider);

    // Determinar módulos permitidos según rol del usuario
    final allowedKeys = _allowedKeysForRole(user?.role);

    // Si la pantalla actual no está permitida para el rol, forzamos la primera permitida (si existe)
    String effectiveKey = currentKey;
    if (allowedKeys.isNotEmpty && !allowedKeys.contains(currentKey)) {
      effectiveKey = allowedKeys.first;
      // actualizar provider para mantener consistencia
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentScreenKeyProvider.notifier).state = effectiveKey;
      });
    }

    // Seleccionar módulo actual usando effectiveKey (o el primero si no existe)
    final currentModule = modules.firstWhere(
      (m) => m['key'] == effectiveKey,
      orElse: () => modules.first,
    );

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
            // Header del Drawer muestra nombre, email y rol (sin cambiar diseño)
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Usuario'),
              accountEmail: Text(user?.email ?? 'Panel Administrativo'),
              currentAccountPicture:
                  const CircleAvatar(child: Icon(Icons.verified_user)),
              decoration: BoxDecoration(color: Colors.blue.shade700),
            ),

            // --- Listado de Módulos (Sección de Navegación) ---
            // Solo mostramos los módulos permitidos por rol, manteniendo orden original
            ...modules
                .where((module) => allowedKeys.isEmpty
                    ? false
                    : allowedKeys.contains(module['key']))
                .map((module) => ListTile(
                      // Usar 'selected' para destacar la opción activa
                      selected: module['key'] == effectiveKey,
                      leading: Icon(module['icon'] as IconData),
                      title: Text(module['title']),
                      onTap: () {
                        // Actualiza el proveedor de estado con la clave del nuevo módulo
                        ref.read(currentScreenKeyProvider.notifier).state =
                            module['key'] as String;
                        Navigator.pop(context); // Cierra el drawer
                      },
                    )),

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
      body: SafeArea(child: currentScreen),
    );
  }
}

// ---------------------- DASHBOARD UI (con estadísticas ficticias) ----------------------
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  // Datos ficticios para mostrar en el dashboard
  Map<String, dynamic> get _mockStats => {
        'clientes': 324,
        'motosRegistradas': 128,
        'ventasHoy': 21,
        'ingresosMes': 15420,
        'citasPendientes': 9,
        'mecanicosActivos': 6,
        'ultimoMesPorDia': [1200, 900, 1500, 1800, 2100, 1600, 1420] // 7 días
      };

  @override
  Widget build(BuildContext context) {
    final stats = _mockStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (ahora usa el nombre real del usuario si está disponible)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mantenemos la estructura original, solo cambiamos el texto para mostrar nombre
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Bienvenido, ${_getUserName(context) ?? 'administrador'}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Resumen del rendimiento — datos ficticios',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Grid de tarjetas de estadísticas
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Clientes',
                        value: '${stats['clientes']}',
                        color: Colors.indigo,
                        icon: Icons.people_outline,
                        subtitle: 'Totales registrados',
                      )),
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Motos',
                        value: '${stats['motosRegistradas']}',
                        color: Colors.teal,
                        icon: Icons.two_wheeler,
                        subtitle: 'Vehículos en inventario',
                      )),
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Ventas hoy',
                        value: '${stats['ventasHoy']}',
                        color: Colors.deepOrange,
                        icon: Icons.point_of_sale,
                        subtitle: 'Transacciones',
                      )),
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Ingresos (mes)',
                        value: '\$${stats['ingresosMes']}',
                        color: Colors.green,
                        icon: Icons.monetization_on_outlined,
                        subtitle: 'Aprox. último mes',
                      )),
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Citas',
                        value: '${stats['citasPendientes']}',
                        color: Colors.purple,
                        icon: Icons.calendar_month_outlined,
                        subtitle: 'Pendientes por asignar',
                      )),
                  _fullWidth(
                      constraints,
                      _StatCard(
                        title: 'Mecánicos',
                        value: '${stats['mecanicosActivos']}',
                        color: Colors.blueGrey,
                        icon: Icons.build_circle_outlined,
                        subtitle: 'Activos ahora',
                      )),
                ],
              );
            },
          ),

          const SizedBox(height: 22),

          // Gráfico simple: ingresos últimos 7 días (mock)
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ingresos últimos 7 días',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: () {
                        final List<int> values = List<int>.from(
                            stats['ultimoMesPorDia'] as Iterable);
                        final int max = values.isEmpty
                            ? 0
                            : values.reduce((int a, int b) => a > b ? a : b);
                        return List.generate(values.length, (i) {
                          final int val = values[i];
                          final heightFactor = max == 0 ? 0.05 : (val / max);
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('\$$val',
                                      style: const TextStyle(fontSize: 11)),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: (heightFactor * 60).clamp(8, 60),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                      [
                                        'Lun',
                                        'Mar',
                                        'Mié',
                                        'Jue',
                                        'Vie',
                                        'Sáb',
                                        'Dom'
                                      ][i],
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        });
                      }(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Actividad esperada y tendencias (solo demo)',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Helper para obtener nombre desde el provider sin pasarlo por constructor
  // (usamos BuildContext aquí para leer el ProviderScope)
  String? _getUserName(BuildContext context) {
    try {
      final container = ProviderScope.containerOf(context);
      final user = container.read(authProvider).user;
      return user?.name;
    } catch (_) {
      return null;
    }
  }
}

class _ResponsiveCardWrapper extends StatelessWidget {
  final double width;
  final Widget child;
  const _ResponsiveCardWrapper({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(value,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(subtitle!,
                          style: Theme.of(context).textTheme.bodySmall),
                    ]
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
