import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';

/// Punto de entrada de la aplicación EcoMora
void main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación (solo portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar Supabase
  try {
    await SupabaseConfig.initialize();
    debugPrint('✅ Aplicación inicializada correctamente');
  } catch (e) {
    debugPrint('❌ Error al inicializar la aplicación: $e');
    // La app continuará aunque falle Supabase (por si el .env no está configurado)
  }

  // Ejecutar la aplicación
  runApp(const EcoMoraApp());
}