// lib/features/alerts/presentation/extensions/alert_ui_ext.dart
import 'package:flutter/material.dart';
import '../../domain/entities/alert.dart';

extension AlertUiX on Alert {
  String get emoji {
    switch (tipoAlerta) {
      case AlertType.phBajo:
      case AlertType.phAlto:
        return '⚗️';
      case AlertType.humBaja:
      case AlertType.humAlta:
        return '💧';
      case AlertType.tempBaja:
      case AlertType.tempAlta:
        return '🌡️';
      case AlertType.nBajo:
      case AlertType.nAlto:
        return '🌿';
      case AlertType.pBajo:
      case AlertType.pAlto:
        return '🌾';
      case AlertType.kBajo:
      case AlertType.kAlto:
        return '🌱';
    }
  }

  /// Color recomendado para UI según severidad
  Color get severityColor {
    final s = severidad;
    if (s == null) return const Color(0xFFF59E0B); // naranja

    switch (s) {
      case AlertSeverity.critica:
        return const Color(0xFFDC2626); // rojo
      case AlertSeverity.alta:
        return const Color(0xFFF59E0B); // naranja
      case AlertSeverity.media:
        return const Color(0xFFFCD34D); // amarillo
      case AlertSeverity.baja:
        return const Color(0xFF10B981); // verde
    }
  }
}
