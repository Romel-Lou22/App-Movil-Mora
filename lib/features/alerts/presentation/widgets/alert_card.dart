import 'package:flutter/material.dart';
import '../../domain/entities/alert.dart';
import 'recommendation_widget.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onTap;

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
          border: Border.all(color: _borderColor(alert.severidad), width: 3),
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
              _buildHeaderImage(context),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationAndClimate(),
                    const SizedBox(height: 16),
                    if ((alert.recomendacion ?? '').trim().isNotEmpty) ...[
                      _buildRecommendation(),
                      const SizedBox(height: 16),
                    ],
                    if (!alert.vista) _buildMarkAsReadButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(gradient: _backgroundGradient(alert.tipoAlerta)),
      child: Stack(
        children: [
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSeverityBadge(),
                _buildTitle(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBadge() {
    final label = _severityLabel(alert.severidad);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _severityColor(alert.severidad),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Text(
          _emojiForType(alert.tipoAlerta),
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _titleForType(alert.tipoAlerta),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(color: Colors.black45, blurRadius: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationAndClimate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              const Text(
                'Tisaleo, Ecuador',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
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
                Text(
                  _temperatureDisplay(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _temperatureColor(),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('|', style: TextStyle(fontSize: 16, color: Colors.black26)),
                const SizedBox(width: 8),
                Text(
                  _humidityDisplay(),
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

  Widget _buildRecommendation() {
    final rec = alert.recomendacion!.trim();

    switch (alert.severidad) {
      case AlertSeverity.critica:
        return CriticalRecommendationWidget(recommendation: rec);
      case AlertSeverity.alta:
        return WarningRecommendationWidget(recommendation: rec);
      case AlertSeverity.media:
      case AlertSeverity.baja:
      case null:
        return RecommendationWidget(recommendation: rec);
    }
  }

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
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ===================== HELPERS (ENUM-SAFE) =====================

  String _severityLabel(AlertSeverity? s) {
    switch (s) {
      case AlertSeverity.critica:
        return 'CRÍTICA';
      case AlertSeverity.alta:
        return 'ALTA';
      case AlertSeverity.media:
        return 'MEDIA';
      case AlertSeverity.baja:
        return 'BAJA';
      case null:
        return 'ALERTA';
    }
  }

  Color _borderColor(AlertSeverity? s) {
    switch (s) {
      case AlertSeverity.critica:
        return const Color(0xFFDC2626);
      case AlertSeverity.alta:
        return const Color(0xFFF59E0B);
      case AlertSeverity.media:
        return const Color(0xFFFCD34D);
      case AlertSeverity.baja:
        return const Color(0xFF10B981);
      case null:
        return Colors.grey;
    }
  }

  Color _severityColor(AlertSeverity? s) => _borderColor(s);

  LinearGradient _backgroundGradient(AlertType type) {
    final map = <AlertType, List<Color>>{
      AlertType.tempBaja: [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
      AlertType.tempAlta: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      AlertType.humBaja: [const Color(0xFFD97706), const Color(0xFF92400E)],
      AlertType.humAlta: [const Color(0xFF06B6D4), const Color(0xFF0E7490)],
      AlertType.phBajo: [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      AlertType.phAlto: [const Color(0xFFEC4899), const Color(0xFFBE185D)],
      AlertType.nBajo: [const Color(0xFF10B981), const Color(0xFF059669)],
      AlertType.nAlto: [const Color(0xFF10B981), const Color(0xFF047857)],
      AlertType.pBajo: [const Color(0xFF14B8A6), const Color(0xFF0F766E)],
      AlertType.pAlto: [const Color(0xFF0EA5E9), const Color(0xFF0369A1)],
      AlertType.kBajo: [const Color(0xFF84CC16), const Color(0xFF65A30D)],
      AlertType.kAlto: [const Color(0xFF22C55E), const Color(0xFF15803D)],
    };

    final colors = map[type] ?? [const Color(0xFF6B7280), const Color(0xFF374151)];

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  String _titleForType(AlertType type) {
    switch (type) {
      case AlertType.phBajo:
        return 'pH Bajo';
      case AlertType.phAlto:
        return 'pH Alto';
      case AlertType.humBaja:
        return 'Humedad Baja';
      case AlertType.humAlta:
        return 'Humedad Alta';
      case AlertType.tempBaja:
        return 'Temperatura Baja';
      case AlertType.tempAlta:
        return 'Temperatura Alta';
      case AlertType.nBajo:
        return 'Nitrógeno Bajo';
      case AlertType.nAlto:
        return 'Nitrógeno Alto';
      case AlertType.pBajo:
        return 'Fósforo Bajo';
      case AlertType.pAlto:
        return 'Fósforo Alto';
      case AlertType.kBajo:
        return 'Potasio Bajo';
      case AlertType.kAlto:
        return 'Potasio Alto';
    }
  }

  String _emojiForType(AlertType type) {
    switch (type) {
      case AlertType.phBajo:
      case AlertType.phAlto:
        return '🧪';
      case AlertType.humBaja:
        return '🌵';
      case AlertType.humAlta:
        return '💧';
      case AlertType.tempBaja:
        return '❄️';
      case AlertType.tempAlta:
        return '🔥';
      case AlertType.nBajo:
        return '🌿';
      case AlertType.nAlto:
        return '⚠️';
      case AlertType.pBajo:
        return '🧬';
      case AlertType.pAlto:
        return '⚗️';
      case AlertType.kBajo:
        return '🍃';
      case AlertType.kAlto:
        return '⚡';
    }
  }

  String _temperatureDisplay() {
    final temp = temperature ?? alert.valorDetectado;
    return '${temp.toStringAsFixed(0)}°C';
  }

  String _humidityDisplay() {
    final hum = humidity ?? 65;
    return '$hum% Hum';
  }

  Color _temperatureColor() {
    final temp = temperature ?? alert.valorDetectado;
    if (temp < 5) return const Color(0xFF3B82F6);
    if (temp > 25) return const Color(0xFFEF4444);
    return const Color(0xFF10B981);
  }
}
