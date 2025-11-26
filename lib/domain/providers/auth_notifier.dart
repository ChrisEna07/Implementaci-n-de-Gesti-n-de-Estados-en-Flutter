import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart'; // Asegúrate de importar

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

  // Función para simular el Login
  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    await Future.delayed(
      const Duration(milliseconds: 700),
    ); // Simular tiempo de respuesta (CA_Login_Calidad)

    try {
      // Regla del Negocio: Credenciales simuladas
      if (email == 'admin@taller.com' && password == '12345') {
        final mockUser = UserModel(
          id: 1,
          name: 'Admin Taller',
          email: email,
          role: 'Administrador',
          telefono: '3001234567',
          token: 'fake_token_123',
        );
        state = AuthState(isAuthenticated: true, user: mockUser);
      } else {
        // Manejo de errores de autenticación (CA_Login_Error)
        state = AuthState(
          errorMessage:
              'Credenciales inválidas. Usuario o contraseña incorrectos.',
        );
      }
    } catch (e) {
      state = AuthState(errorMessage: 'Error de conexión.');
    }
  }

  void logout() {
    state = AuthState();
  }
}
