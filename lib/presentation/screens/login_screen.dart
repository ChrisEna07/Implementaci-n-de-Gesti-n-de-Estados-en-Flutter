import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/auth_notifier.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // Controladores de texto
    final emailController = TextEditingController(text: 'admin@taller.com');
    final passwordController = TextEditingController(text: '12345');

    // Muestra errores de autenticación (CA_Login_Error)
    ref.listen<AuthState>(authProvider, (previous, current) {
      if (current.errorMessage != null && current.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(current.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Taller E-commerce Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Input de Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              // Input de Contraseña
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),
              // Botón de Login (maneja estado de carga)
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () {
                        // Llama a la función de login del Notifier
                        authNotifier.login(
                          emailController.text,
                          passwordController.text,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 10),
              // Mostrar Rol de prueba
              const Text('Prueba con: admin@taller.com / 12345'),
            ],
          ),
        ),
      ),
    );
  }
}
