/// Constantes para las rutas de navegación de la aplicación
/// Evita errores de tipeo y centraliza los nombres de rutas
class AppRoutes {
  // Constructor privado para evitar instanciación
  AppRoutes._();

  // === Rutas de Autenticación ===

  /// Ruta de login
  static const String login = '/login';

  /// Ruta de registro
  static const String register = '/register';

  /// Ruta de recuperación de contraseña
  static const String forgotPassword = '/forgot-password';

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

  // === Ruta Inicial ===

  /// Ruta inicial de la aplicación (login)
  static const String initial = login;
}