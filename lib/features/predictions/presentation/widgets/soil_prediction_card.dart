import 'package:flutter/material.dart';
import '../../domain/entities/soil_prediction.dart';
import '../../domain/entities/weather_data.dart';

/// Card que muestra la predicción de nutrientes del suelo
///
/// Muestra:
/// - pH del suelo
/// - Nitrógeno (N)
/// - Fósforo (P)
/// - Potasio (K)
/// - Indicadores de estado para cada nutriente
/// - Recomendaciones si hay valores fuera del rango
class SoilPredictionCard extends StatelessWidget {
  final SoilPrediction soilPrediction;
  final WeatherData weatherData;


  const SoilPredictionCard({
    super.key,
    required this.soilPrediction,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    final soil = soilPrediction.copyWith(humedad: weatherData.humedad.toDouble());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              '🌱 Predicción de Nutrientes del Suelo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7C3B),
              ),
            ),

            const SizedBox(height: 4),

            // Subtítulo con fecha
            Text(
              'Análisis predictivo para hoy',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 20),

            // pH
            _NutrientIndicator(
              icon: '⚗️',
              label: 'pH del Suelo',
              value: soilPrediction.ph.toStringAsFixed(2),
              unit: '',
              isOptimal: soilPrediction.phIsOptimal,
              isLow: soilPrediction.phIsLow,
              isHigh: soilPrediction.phIsHigh,
              optimalRange: '${SoilPrediction.phMin} - ${SoilPrediction.phMax}',
              recommendation: '',
            ),

            const Divider(height: 24),

            // Nitrógeno
            _NutrientIndicator(
              icon: '🌿',
              label: 'Nitrógeno (N)',
              value: soilPrediction.nitrogeno.toStringAsFixed(2),
              unit: 'ppm',
              isOptimal: soilPrediction.nitrogenoIsOptimal,
              isLow: soilPrediction.nitrogenoIsLow,
              isHigh: soilPrediction.nitrogenoIsHigh,
              optimalRange: '${SoilPrediction.nitrogenoMin.toInt()} - ${SoilPrediction.nitrogenoMax.toInt()} ppm',
              recommendation: '',
            ),

            const Divider(height: 24),

            // Fósforo
            _NutrientIndicator(
              icon: '🌾',
              label: 'Fósforo (P)',
              value: soilPrediction.fosforo.toStringAsFixed(2),
              unit: 'ppm',
              isOptimal: soilPrediction.fosforoIsOptimal,
              isLow: soilPrediction.fosforoIsLow,
              isHigh: soilPrediction.fosforoIsHigh,
              optimalRange: '${SoilPrediction.fosforoMin.toInt()} - ${SoilPrediction.fosforoMax.toInt()} ppm',
              recommendation: '',
            ),

            const Divider(height: 24),

            // Potasio
            _NutrientIndicator(
              icon: '🌱',
              label: 'Potasio (K)',
              value: soilPrediction.potasio.toStringAsFixed(2),
              unit: 'ppm',
              isOptimal: soilPrediction.potasioIsOptimal,
              isLow: soilPrediction.potasioIsLow,
              isHigh: soilPrediction.potasioIsHigh,
              optimalRange: '${SoilPrediction.potasioMin.toInt()} - ${SoilPrediction.potasioMax.toInt()} ppm',
              recommendation: '',
            ),

            const SizedBox(height: 16),

            // Agua
            _NutrientIndicator(
              icon: '💧',
              label: 'Humedad del Suelo',
              value: soil.humedad != null ? '${soil.humedad!.round()}' : '--',
              unit: '%',
              isOptimal: soil.humedadIsOptimal,
              isLow: soil.humedadIsLow,
              isHigh: soil.humedadIsHigh,
              optimalRange:
              '${SoilPrediction.humedadMin.toInt()} - ${SoilPrediction.humedadMax.toInt()} %',
              recommendation: '',
            ),


            const SizedBox(height: 16),


            // Resumen general
            //_buildSummary(),

            const SizedBox(height: 12),

            // Indicador de fuente de datos
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology_outlined, size: 14, color: Color(0xFF999999)),
                SizedBox(width: 4),
                Text(
                  'Datos API',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  /// Construye el resumen general del estado del suelo
  Widget _buildSummary() {
    final allOptimal = soilPrediction.allOptimal;
    final recommendations = soilPrediction.allRecommendations;

    if (allOptimal) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF388E3C), size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Todos los nutrientes están en rango óptimo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF388E3C),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (recommendations.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF57C00).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFFF57C00), size: 18),
                SizedBox(width: 6),
                Text(
                  'Recomendaciones',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF57C00),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${rec.split(': ')[1]}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            )),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

/// Widget que muestra un indicador individual de nutriente
class _NutrientIndicator extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String unit;
  final bool isOptimal;
  final bool isLow;
  final bool isHigh;
  final String optimalRange;
  final String? recommendation;

  const _NutrientIndicator({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.isOptimal,
    required this.isLow,
    required this.isHigh,
    required this.optimalRange,
    this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila principal con valor e indicador
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            _buildStatusBadge(),
          ],
        ),

        const SizedBox(height: 8),

        // Rango óptimo
        Text(
          'Rango óptimo: $optimalRange',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF999999),
          ),
        ),

        // Recomendación si existe
        if (recommendation != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '💡 $recommendation',
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Construye el badge de estado
  Widget _buildStatusBadge() {
    Color backgroundColor;
    String text;
    Color textColor;
    IconData icon;

    if (isOptimal) {
      backgroundColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF388E3C);
      text = 'Óptimo';
      icon = Icons.check_circle;
    } else if (isLow) {
      backgroundColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1976D2);
      text = 'Bajo';
      icon = Icons.arrow_downward;
    } else {
      backgroundColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFF57C00);
      text = 'Alto';
      icon = Icons.arrow_upward;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}