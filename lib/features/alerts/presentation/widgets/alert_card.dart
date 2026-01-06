import 'package:flutter/material.dart';
import '../../domain/entities/alert.dart';
import 'recommendation_widget.dart';

/// Card completo de alerta según el diseño
///
/// Muestra:
/// - Imagen/gradiente de fondo según tipo
/// - Badge de severidad
/// - Título con emoji
/// - Ubicación del lote
/// - Datos del clima
/// - Recomendación
/// - Botón para marcar como vista
class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onTap;

  // Datos del clima (temporal hasta conectar WeatherProvider)
  // TODO: Conectar con WeatherProvider
  final double? temperature;
  final int? humidity;

  const AlertCard({
    super.key,
    required this.alert,
    this.onMarkAsRead,
    this.onTap,
    this.temperature,
    this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Borde según severidad
          border: Border.all(
            color: _getBorderColor(),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de fondo con título
              _buildHeaderImage(context),

              // Contenido del card
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ubicación y clima
                    _buildLocationAndClimate(),

                    const SizedBox(height: 16),

                    // Recomendación (si existe)
                    if (alert.recomendacion != null &&
                        alert.recomendacion!.isNotEmpty)
                      _buildRecommendation(),

                    if (alert.recomendacion != null &&
                        alert.recomendacion!.isNotEmpty)
                      const SizedBox(height: 16),

                    // Botón de marcar como vista (solo si no está vista)
                    if (!alert.vista)
                      _buildMarkAsReadButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header con imagen de fondo y título
  Widget _buildHeaderImage(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: _getBackgroundGradient(),
      ),
      child: Stack(
        children: [
          // TODO: Reemplazar con imagen real cuando tengas los assets
          // Image.asset(
          //   _getAlertImage(),
          //   fit: BoxFit.cover,
          //   width: double.infinity,
          //   height: double.infinity,
          // ),

          // Overlay oscuro para legibilidad
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Contenido del header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Badge de severidad
                _buildSeverityBadge(),

                // Título con emoji
                _buildTitle(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Badge de severidad (CRÍTICA, PREVENTIVA, etc.)
  Widget _buildSeverityBadge() {
    final severity = alert.severidad?.toUpperCase() ?? 'ALERTA';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getSeverityColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        severity,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Título de la alerta con emoji
  Widget _buildTitle() {
    return Row(
      children: [
        // Emoji según tipo de alerta
        Text(
          alert.emoji,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(width: 12),

        // Título
        Expanded(
          child: Text(
            _getAlertTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Sección de ubicación y clima
  Widget _buildLocationAndClimate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ubicación
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UBICACIÓN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                // TODO: Reemplazar con nombre de parcela real
                'Tisaleo, Ecuador',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Clima
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'CLIMA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                // Temperatura
                Text(
                  _getTemperatureDisplay(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _getTemperatureColor(),
                  ),
                ),
                const SizedBox(width: 8),

                // Separador
                const Text(
                  '|',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black26,
                  ),
                ),
                const SizedBox(width: 8),

                // Humedad
                Text(
                  _getHumidityDisplay(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Widget de recomendación
  Widget _buildRecommendation() {
    // Usar variante según severidad
    if (alert.severidad?.toLowerCase() == 'critica') {
      return CriticalRecommendationWidget(
        recommendation: alert.recomendacion!,
      );
    } else if (alert.severidad?.toLowerCase() == 'alta' ||
        alert.severidad?.toLowerCase() == 'preventiva') {
      return WarningRecommendationWidget(
        recommendation: alert.recomendacion!,
      );
    } else {
      return RecommendationWidget(
        recommendation: alert.recomendacion!,
      );
    }
  }

  /// Botón para marcar como vista
  Widget _buildMarkAsReadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onMarkAsRead,
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: const Text(
          'MARCAR COMO VISTA',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A), // Morado
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ========== HELPERS ==========

  /// Obtiene el color del borde según severidad
  Color _getBorderColor() {
    if (alert.severidad == null) return Colors.grey;

    switch (alert.severidad!.toLowerCase()) {
      case 'critica':
        return const Color(0xFFDC2626); // Rojo
      case 'alta':
      case 'preventiva':
        return const Color(0xFFF59E0B); // Amarillo/Naranja
      case 'media':
        return const Color(0xFFFCD34D); // Amarillo claro
      case 'baja':
      case 'normal':
        return const Color(0xFF10B981); // Verde
      default:
        return Colors.grey;
    }
  }

  /// Obtiene el color del badge de severidad
  Color _getSeverityColor() {
    if (alert.severidad == null) return Colors.grey;

    switch (alert.severidad!.toLowerCase()) {
      case 'critica':
        return const Color(0xFFDC2626);
      case 'alta':
      case 'preventiva':
        return const Color(0xFFF59E0B);
      case 'media':
        return const Color(0xFFFCD34D);
      case 'baja':
      case 'normal':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  /// Obtiene el gradiente de fondo según tipo de alerta
  LinearGradient _getBackgroundGradient() {
    // Gradientes según tipo de alerta
    final gradients = {
      'helada': [const Color(0xFF3B82F6), const Color(0xFF1E40AF)], // Azul
      'temp_baja': [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
      'sequia': [const Color(0xFFEF4444), const Color(0xFFB91C1C)], // Rojo
      'hum_baja': [const Color(0xFFD97706), const Color(0xFF92400E)], // Naranja
      'hum_alta': [const Color(0xFF06B6D4), const Color(0xFF0E7490)], // Cyan
      'ph_bajo': [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)], // Morado
      'ph_alto': [const Color(0xFFEC4899), const Color(0xFFBE185D)], // Rosa
      'temp_alta': [const Color(0xFFF59E0B), const Color(0xFFD97706)], // Amarillo
      'n_bajo': [const Color(0xFF10B981), const Color(0xFF059669)], // Verde
      'p_bajo': [const Color(0xFF14B8A6), const Color(0xFF0F766E)], // Teal
      'k_bajo': [const Color(0xFF84CC16), const Color(0xFF65A30D)], // Lima
    };

    final colors = gradients[alert.tipoAlerta] ??
        [const Color(0xFF6B7280), const Color(0xFF374151)]; // Gris

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  /// Obtiene el título formateado de la alerta
  String _getAlertTitle() {
    final titles = {
      'helada': 'Helada',
      'temp_baja': 'Temperatura Baja',
      'temp_alta': 'Temperatura Alta',
      'sequia': 'Sequía',
      'hum_baja': 'Humedad Baja',
      'hum_alta': 'Humedad Alta',
      'ph_bajo': 'pH Bajo',
      'ph_alto': 'pH Alto',
      'n_bajo': 'Nitrógeno Bajo',
      'n_alto': 'Nitrógeno Alto',
      'p_bajo': 'Fósforo Bajo',
      'p_alto': 'Fósforo Alto',
      'k_bajo': 'Potasio Bajo',
      'k_alto': 'Potasio Alto',
    };

    return titles[alert.tipoAlerta] ?? 'Alerta';
  }

  /// Obtiene el display de temperatura
  String _getTemperatureDisplay() {
    // TODO: Reemplazar con temperatura de WeatherProvider
    // final temp = temperature ?? weather?.temperature ?? alert.valorDetectado;

    final temp = temperature ?? alert.valorDetectado;
    return '${temp.toStringAsFixed(0)}°C';
  }

  /// Obtiene el display de humedad
  String _getHumidityDisplay() {
    // TODO: Reemplazar con humedad de WeatherProvider
    // final hum = humidity ?? weather?.humidity ?? 65;

    final hum = humidity ?? 65;
    return '$hum% Hum';
  }

  /// Obtiene el color de la temperatura
  Color _getTemperatureColor() {
    final temp = temperature ?? alert.valorDetectado;

    if (temp < 5) return const Color(0xFF3B82F6); // Azul (frío)
    if (temp > 25) return const Color(0xFFEF4444); // Rojo (calor)
    return const Color(0xFF10B981); // Verde (normal)
  }

  /// Obtiene la ruta del asset de imagen según tipo
  /// TODO: Implementar cuando tengas las imágenes
  String _getAlertImage() {
    final images = {
      'helada': 'assets/images/alerts/frost.jpg',
      'sequia': 'assets/images/alerts/drought.jpg',
      'ph_bajo': 'assets/images/alerts/soil_acidic.jpg',
      'hum_baja': 'assets/images/alerts/dry_soil.jpg',
      'temp_baja': 'assets/images/alerts/cold.jpg',
      'temp_alta': 'assets/images/alerts/heat.jpg',
      'n_bajo': 'assets/images/alerts/nitrogen.jpg',
    };

    return images[alert.tipoAlerta] ?? 'assets/images/alerts/default.jpg';
  }
}