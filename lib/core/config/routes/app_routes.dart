/// Constantes para las rutas de navegación de la aplicación
/// Evita errores de tipeo y centraliza los nombres de rutas
class AppRoutes {
  // Constructor privado para evitar instanciación
  AppRoutes._();

  // === Ruta de Splash - ✅ AGREGADO ===

  /// Ruta del splash screen (pantalla de carga inicial)
  static const String splash = '/';

  // === Rutas de Autenticación ===

  /// Ruta de login
  static const String login = '/login';

  /// Ruta de registro
  static const String register = '/register';

  /// Ruta de recuperación de contraseña
  static const String forgotPassword = '/forgot-password';

  //===carga de datos inicial===

  static const String loading = '/loading';


  // === Rutas Principales ===

  /// Ruta de la pantalla principal (home/dashboard)
  static const String home = '/home';

  /// Ruta de predicciones
  static const String predictions = '/predictions';

  /// Ruta de alertas
  static const String alerts = '/alerts';

  /// Ruta de parcelas
  static const String parcelas = '/parcelas';

  /// Ruta de perfil
  static const String profile = '/profile';

  // === Rutas Secundarias ===

  /// Ruta para agregar nueva parcela
  static const String addParcela = '/parcelas/add';

  /// Ruta para editar parcela
  static const String editParcela = '/parcelas/edit';

  /// Ruta para ver detalle de parcela
  static const String parcelaDetail = '/parcelas/detail';

  /// Ruta para ver histórico de datos
  static const String historical = '/historical';

  /// Ruta de configuración
  static const String settings = '/settings';

  /// Ruta de estadísticas (gráficas)
  static const String statistics = '/statistics';

// NOTA: profile fue reemplazado por statistics

  // === Ruta Inicial - ✅ CAMBIADO ===

  /// Ruta inicial de la aplicación (splash screen)
  static const String initial = splash; // ← Cambiado de login a splash
}