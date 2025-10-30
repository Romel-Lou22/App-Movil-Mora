import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración de Supabase para la aplicación
/// Proporciona una única instancia del cliente para toda la aplicación
class SupabaseConfig {
  // Instancia única (Singleton)
  static SupabaseConfig? _instance;

  // Cliente de Supabase
  late final SupabaseClient _client;

  // Constructor privado
  SupabaseConfig._();

  /// Obtiene la instancia única de la configuración
  static SupabaseConfig get instance {
    _instance ??= SupabaseConfig._();
    return _instance!;
  }

  /// Inicializa Supabase con las credenciales del archivo .env
  /// Debe llamarse en main() antes de runApp()
  static Future<void> initialize() async {
    try {
      // Cargar variables de entorno
      await dotenv.load(fileName: ".env");

      // Obtener credenciales desde .env
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      // Validar que existan las credenciales
      if (supabaseUrl == null || supabaseUrl.isEmpty) {
        throw Exception('SUPABASE_URL no encontrado en .env');
      }

      if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
        throw Exception('SUPABASE_ANON_KEY no encontrado en .env');
      }

      // Inicializar Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        // Configuraciones adicionales opcionales
        debug: true, // Cambia a false en producción
      );

      print('✅ Supabase inicializado correctamente');
    } catch (e) {
      print('❌ Error al inicializar Supabase: $e');
      rethrow;
    }
  }

  /// Obtiene el cliente de Supabase
  /// Usar: SupabaseConfig.instance.client
  SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception(
        'Supabase no ha sido inicializado. '
            'Llama a SupabaseConfig.initialize() en main()',
      );
    }
  }

  /// Atajo directo al cliente de Supabase
  /// Usar: supabase.auth.signIn(...)
  static SupabaseClient get supabase => instance.client;

  /// Obtiene el usuario actual autenticado
  User? get currentUser => client.auth.currentUser;

  /// Obtiene el session actual
  Session? get currentSession => client.auth.currentSession;

  /// Verifica si hay un usuario autenticado
  bool get isAuthenticated => currentUser != null;

  /// Stream que emite cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}

/// Atajo global para acceder al cliente de Supabase
/// Uso: supabase.auth.signIn(...)
final supabase = SupabaseConfig.supabase;