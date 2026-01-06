import 'package:flutter/material.dart';

/// Widget que muestra la recomendación de una alerta
///
/// Diseño: Fondo rosa claro con ícono y texto
class RecommendationWidget extends StatelessWidget {
  final String recommendation;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const RecommendationWidget({
    super.key,
    required this.recommendation,
    this.icon = Icons.lightbulb_outline,
    this.backgroundColor = const Color(0xFFFCE4EC), // Rosa claro
    this.textColor = const Color(0xFFC2185B), // Rosa oscuro
    this.iconColor = const Color(0xFFC2185B),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),

          // Texto de recomendación
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECOMENDACIÓN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de recomendación con estilo de advertencia (amarillo)
class WarningRecommendationWidget extends StatelessWidget {
  final String recommendation;

  const WarningRecommendationWidget({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return RecommendationWidget(
      recommendation: recommendation,
      icon: Icons.warning_amber_rounded,
      backgroundColor: const Color(0xFFFFF9C4), // Amarillo claro
      textColor: const Color(0xFFF57C00), // Naranja oscuro
      iconColor: const Color(0xFFF57C00),
    );
  }
}

/// Widget de recomendación con estilo de éxito (verde)
class SuccessRecommendationWidget extends StatelessWidget {
  final String recommendation;

  const SuccessRecommendationWidget({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return RecommendationWidget(
      recommendation: recommendation,
      icon: Icons.check_circle_outline,
      backgroundColor: const Color(0xFFE8F5E9), // Verde claro
      textColor: const Color(0xFF2E7D32), // Verde oscuro
      iconColor: const Color(0xFF2E7D32),
    );
  }
}

/// Widget de recomendación con estilo crítico (rojo)
class CriticalRecommendationWidget extends StatelessWidget {
  final String recommendation;

  const CriticalRecommendationWidget({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return RecommendationWidget(
      recommendation: recommendation,
      icon: Icons.error_outline,
      backgroundColor: const Color(0xFFFFEBEE), // Rojo claro
      textColor: const Color(0xFFC62828), // Rojo oscuro
      iconColor: const Color(0xFFC62828),
    );
  }
}