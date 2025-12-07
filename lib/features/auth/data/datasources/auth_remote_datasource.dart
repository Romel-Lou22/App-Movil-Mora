import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/user_model.dart';

/// Fuente de datos remota para autenticación
/// Se comunica directamente con Supabase Auth
/// Contiene SOLO las llamadas a la API, sin lógica de negocio
abstract class AuthRemoteDataSource {
  /// Inicia sesión con email y contraseña
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario
  Future<UserModel> register({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  });

  /// Cierra la sesión del usuario actual
  Future<void> logout();

  /// Obtiene el usuario actual si está autenticado
  Future<UserModel?> getCurrentUser();

  /// Envía un email para restablecer la contraseña
  Future<void> resetPassword({required String email});

  /// Stream que emite el usuario cuando cambia el estado de autenticación
  Stream<UserModel?> get authStateChanges;
}

/// Implementación del DataSource usando Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  AuthRemoteDataSourceImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseConfig.supabase;
  final SupabaseClient _supabase;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Verificar que el usuario no sea null
      if (response.user == null) {
        throw Exception('No se pudo obtener el usuario después del login');
      }

      // Convertir el User de Supabase a nuestro UserModel
      return _mapSupabaseUserToModel(response.user!);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    String? fullName,
    String? phone
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );

      // Verificar que el usuario no sea null
      if (response.user == null) {
        throw Exception('No se pudo crear el usuario');
      }

      // Convertir el User de Supabase a nuestro UserModel
      return _mapSupabaseUserToModel(response.user!);
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        return null;
      }

      return _mapSupabaseUserToModel(user);
    } catch (e) {
      throw Exception('Error al obtener usuario actual: $e');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Error al enviar email de recuperación: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;
      return _mapSupabaseUserToModel(user);
    });
  }

  /// Método auxiliar para convertir User de Supabase a UserModel
  UserModel _mapSupabaseUserToModel(User supabaseUser) {
    return UserModel.fromJson({
      'id': supabaseUser.id,
      'email': supabaseUser.email ?? '',
      'user_metadata': supabaseUser.userMetadata ?? {},
      'created_at': supabaseUser.createdAt,
      'updated_at': supabaseUser.updatedAt,
      'email_confirmed_at': supabaseUser.emailConfirmedAt,
    });
  }
}