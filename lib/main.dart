import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart'; // ← IMPORTAR EL APP.DART CORRECTO
import 'core/config/supabase_config.dart';

/// Punto de entrada de la aplicación EcoMora
void main() async {
  debugPrint('🚀 [MAIN] Iniciando aplicación EcoMora...');

  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('✅ [MAIN] WidgetsFlutterBinding inicializado');

  // Configurar orientación (solo portrait)
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint('✅ [MAIN] Orientación configurada a portrait');
  } catch (e) {
    debugPrint('❌ [MAIN] Error configurando orientación: $e');
  }

  // Inicializar Supabase
  try {
    debugPrint('⏳ [MAIN] Inicializando Supabase...');
    await SupabaseConfig.initialize();
    debugPrint('✅ [MAIN] Supabase inicializado correctamente');
  } catch (e) {
    debugPrint('❌ [MAIN] Error al inicializar Supabase: $e');
    // La app continuará aunque falle Supabase
  }

  debugPrint('🎬 [MAIN] Ejecutando runApp()...');

  // ===== IMPORTANTE: Usar EcoMoraApp de app.dart =====
  runApp(const EcoMoraApp());

  debugPrint('✅ [MAIN] runApp() ejecutado');
}

// ===== ELIMINAR TODA LA CLASE EcoMoraApp DE AQUÍ =====
// Ya no se necesita porque usamos la de app.dart