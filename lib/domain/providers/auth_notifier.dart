import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final String? errorMessage;
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  // Simulación de LOGIN con múltiples roles
  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 700)); // simular backend

    try {
      // --------------------------  ADMIN  ---------------------------------
      if (email == 'admin@taller.com' && password == '12345') {
        final mockUser = UserModel(
          id: 1,
          name: 'Admin Taller',
          email: email,
          role: 'Administrador',
          telefono: '3001234567',
          token: 'token_admin',
        );
        state = AuthState(isAuthenticated: true, user: mockUser);
        return;
      }

      // --------------------------  CLIENTE  --------------------------------
      if (email == 'cliente@taller.com' && password == '12345') {
        final mockUser = UserModel(
          id: 2,
          name: 'Cliente Registrado',
          email: email,
          role: 'Cliente',
          telefono: '3109876543',
          token: 'token_cliente',
        );
        state = AuthState(isAuthenticated: true, user: mockUser);
        return;
      }

      // --------------------------  MECÁNICO  --------------------------------
      if (email == 'mecanico@taller.com' && password == '12345') {
        final mockUser = UserModel(
          id: 3,
          name: 'Mecánico del Taller',
          email: email,
          role: 'Mecanico',
          telefono: '3205558899',
          token: 'token_mecanico',
        );
        state = AuthState(isAuthenticated: true, user: mockUser);
        return;
      }

      // ----------- Si no coincide con ningún rol → error --------------------
      state = AuthState(
        errorMessage:
            'Credenciales inválidas. Usuario o contraseña incorrectos.',
      );
    } catch (e) {
      state = AuthState(errorMessage: 'Error de conexión.');
    }
  }

  void logout() {
    state = AuthState();
  }
}
