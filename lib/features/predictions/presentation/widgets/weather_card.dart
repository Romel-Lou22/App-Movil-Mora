import 'package:flutter/material.dart';
import '../../domain/entities/weather_data.dart';

/// Card que muestra los datos climáticos actuales
///
/// Muestra:
/// - Icono del clima (desde OpenWeather)
/// - Temperatura en °C
/// - Humedad en %
/// - Descripción del clima
/// - Indicadores de estado (óptimo/alto/bajo)
class WeatherCard extends StatelessWidget {
  final WeatherData weatherData;
  final VoidCallback? onRefresh;

  const WeatherCard({
    super.key,
    required this.weatherData,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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
            // Header con título y botón de refresh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '☁️ Condiciones Climáticas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7C3B),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: onRefresh,
                    color: const Color(0xFF6B7C3B),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Contenido principal con icono y datos
            Row(
              children: [
                // Icono del clima (si existe)
                if (weatherData.iconUrl != null)
                  Image.network(
                    weatherData.iconUrl!,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        weatherData.weatherEmoji,
                        style: const TextStyle(fontSize: 60),
                      );
                    },
                  )
                else
                  Text(
                    weatherData.weatherEmoji,
                    style: const TextStyle(fontSize: 60),
                  ),

                const SizedBox(width: 20),

                // Datos climáticos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Temperatura
                      _buildDataRow(
                        icon: '🌡️',
                        label: 'Temperatura',
                        value: '${weatherData.temperatura.round()}°C',
                        status: _getTemperatureStatus(),
                      ),

                      const SizedBox(height: 12),

                      // Humedad

                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Descripción del clima
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                weatherData.descripcionClima,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            // Indicador de fuente de datos
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_outlined, size: 14, color: Color(0xFF999999)),
                SizedBox(width: 4),
                Text(
                  'Datos en tiempo real',
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

  /// Construye una fila de datos con icono, label, valor y estado
  Widget _buildDataRow({
    required String icon,
    required String label,
    required String value,
    required _DataStatus status,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(status),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye un badge de estado (óptimo/alto/bajo)
  Widget _buildStatusBadge(_DataStatus status) {
    Color backgroundColor;
    String text;
    Color textColor;

    switch (status) {
      case _DataStatus.optimal:
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF388E3C);
        text = 'Óptimo';
        break;
      case _DataStatus.high:
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFF57C00);
        text = 'Alto';
        break;
      case _DataStatus.low:
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        text = 'Bajo';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  /// Obtiene el estado de la temperatura
  _DataStatus _getTemperatureStatus() {
    if (weatherData.isOptimalTemperature) {
      return _DataStatus.optimal;
    } else if (weatherData.isHot) {
      return _DataStatus.high;
    } else {
      return _DataStatus.low;
    }
  }

  /// Obtiene el estado de la humedad
  _DataStatus _getHumidityStatus() {
    if (weatherData.isOptimalHumidity) {
      return _DataStatus.optimal;
    } else if (weatherData.isHighHumidity) {
      return _DataStatus.high;
    } else {
      return _DataStatus.low;
    }
  }
}

/// Estados posibles de un dato
enum _DataStatus {
  optimal, // Valor óptimo
  high,    // Valor alto
  low,     // Valor bajo
}