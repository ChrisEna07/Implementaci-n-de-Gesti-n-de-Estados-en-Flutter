import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importa las pantallas que usarás para la navegación
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';

// Importa el proveedor de autenticación que hemos creado (simulación)
// Nota: En nuestra estructura, esto sería 'states/auth_notifier.dart'
// Asumo que tu ruta es 'domain/providers/auth_notifier.dart' según tu código.
import 'domain/providers/auth_notifier.dart';

void main() {
  // Envuelve la aplicación con ProviderScope para usar Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escucha el estado de autenticación (isAuthenticated)
    // El nombre del proveedor debe coincidir con el que usamos en 'auth_notifier.dart' (authNotifierProvider)
    // Usando 'authProvider' como tú lo indicaste, asumiendo que está definido en domain/providers/auth_notifier.dart
    final authState = ref.watch(authProvider);

    return MaterialApp(
      // Nombre de la aplicación actualizado
      title: 'Rafa Motos Gestión de Estados',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Cambiado a un color más adecuado para "Motos" o un tono vibrante
        primarySwatch: Colors.red,
        primaryColor: Colors.redAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
        ),
      ),
      // 2. Define la pantalla inicial basada en el estado de autenticación
      // Si está autenticado (true), va a HomeScreen. Si no, va a LoginScreen.
      home:
          authState.isAuthenticated ? const HomeScreen() : const LoginScreen(),
    );
  }
}
