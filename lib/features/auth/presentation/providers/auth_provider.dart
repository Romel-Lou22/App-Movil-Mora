import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../../../core/errors/failures.dart';

/// Estados posibles de la autenticación
enum AuthStatus {
  initial,      // Estado inicial
  loading,      // Procesando (login, logout, etc.)
  authenticated, // Usuario autenticado
  unauthenticated, // Sin autenticación
  error,        // Error en autenticación
}

/// Provider para manejar el estado de autenticación
/// Usa ChangeNotifier de Provider para gestión de estado
class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  // TODO: Agregar más UseCases cuando los necesites:
  // final LogoutUseCase logoutUseCase;
  // final RegisterUseCase registerUseCase;
  // final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthProvider({
    required this.loginUseCase,
  });

  // === Estado ===
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  // === Getters ===
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  // Getters de conveniencia
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get hasError => _status == AuthStatus.error;

  // === Métodos de Autenticación ===

  /// Inicia sesión con email y contraseña
  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Cambiar estado a loading
    _setStatus(AuthStatus.loading);
    _errorMessage = null;

    // Ejecutar el caso de uso
    final result = await loginUseCase(
      email: email,
      password: password,
    );

    // Manejar el resultado
    result.fold(
      // Error (Left)
          (failure) {
        _setStatus(AuthStatus.error);
        _errorMessage = failure.message;
        _user = null;
      },
      // Éxito (Right)
          (user) {
        _setStatus(AuthStatus.authenticated);
        _user = user;
        _errorMessage = null;
      },
    );
  }

  /// Cierra la sesión del usuario
  /// TODO: Implementar cuando tengamos LogoutUseCase
  Future<void> logout() async {
    _setStatus(AuthStatus.loading);

    // Simular logout por ahora
    await Future.delayed(const Duration(milliseconds: 500));

    _setStatus(AuthStatus.unauthenticated);
    _user = null;
    _errorMessage = null;
  }

  /// Verifica si hay un usuario autenticado al iniciar la app
  /// TODO: Implementar cuando tengamos GetCurrentUserUseCase
  Future<void> checkAuthStatus() async {
    _setStatus(AuthStatus.loading);

    // Simular verificación por ahora
    await Future.delayed(const Duration(milliseconds: 500));

    // Por ahora, siempre retorna no autenticado
    _setStatus(AuthStatus.unauthenticated);
    _user = null;
  }

  /// Limpia el mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Cambia el estado y notifica a los listeners
  void _setStatus(AuthStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  /// Resetea el provider al estado inicial
  void reset() {
    _status = AuthStatus.initial;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }
}