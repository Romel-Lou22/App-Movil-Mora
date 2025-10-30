import 'package:flutter/material.dart';

/// Colores de la aplicación EcoMora
/// Basados en el diseño de la pantalla de login
class AppColors {
  // Constructor privado para evitar instanciación
  AppColors._();

  // === Colores Principales ===

  /// Verde oliva principal del logo y tema
  static const Color primary = Color(0xFF6B7C3B);

  /// Verde más oscuro para variaciones
  static const Color primaryDark = Color(0xFF566230);

  /// Verde más claro para fondos sutiles
  static const Color primaryLight = Color(0xFF8A9D5C);

  // === Colores Secundarios ===

  /// Púrpura oscuro del botón principal
  static const Color secondary = Color(0xFF5C2E5C);

  /// Púrpura más oscuro para hover/pressed
  static const Color secondaryDark = Color(0xFF4A2449);

  /// Púrpura más claro para estados disabled
  static const Color secondaryLight = Color(0xFF7D4A7D);

  // === Colores de Fondo ===

  /// Fondo principal de la app
  static const Color background = Color(0xFFF5F5F5);

  /// Fondo de cards y containers
  static const Color surface = Color(0xFFFFFFFF);

  /// Fondo de inputs
  static const Color inputBackground = Color(0xFFFFFFFF);

  // === Colores de Texto ===

  /// Texto principal oscuro
  static const Color textPrimary = Color(0xFF2D2D2D);

  /// Texto secundario gris
  static const Color textSecondary = Color(0xFF757575);

  /// Texto en botones blancos
  static const Color textOnButton = Color(0xFFFFFFFF);

  /// Texto de hint en inputs
  static const Color textHint = Color(0xFFBDBDBD);

  // === Colores de Estado ===

  /// Color de error
  static const Color error = Color(0xFFD32F2F);

  /// Color de éxito
  static const Color success = Color(0xFF388E3C);

  /// Color de advertencia
  static const Color warning = Color(0xFFF57C00);

  /// Color de información
  static const Color info = Color(0xFF1976D2);

  // === Colores de Bordes ===

  /// Borde de inputs
  static const Color border = Color(0xFFE0E0E0);

  /// Borde activo/focus
  static const Color borderActive = Color(0xFF6B7C3B);

  /// Borde de error
  static const Color borderError = Color(0xFFD32F2F);

  // === Colores de Iconos ===

  /// Icono principal (verde)
  static const Color iconPrimary = Color(0xFF6B7C3B);

  /// Icono secundario (gris)
  static const Color iconSecondary = Color(0xFF757575);

  /// Icono en botones
  static const Color iconOnButton = Color(0xFFFFFFFF);
}