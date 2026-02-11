import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/statistics_provider.dart';

/// Sección de análisis clave del mes
class InsightsSection extends StatelessWidget {
  const InsightsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        if (!provider.hasData) {
          return const SizedBox.shrink();
        }

        final summary = provider.summary;
        final totalAlertas = summary['total'] as int? ?? 0;

        if (totalAlertas == 0) {
          return _buildNoAlertsInsight();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Análisis del Mes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _buildCriticalAlertsInsight(summary),
            const SizedBox(height: 12),
            _buildMostAffectedParameterInsight(summary),
            const SizedBox(height: 12),
            _buildCriticalWeekInsight(summary),
          ],
        );
      },
    );
  }

  /// Insight de alertas críticas
  Widget _buildCriticalAlertsInsight(Map<String, dynamic> summary) {
    final criticas = summary['criticas'] as int? ?? 0;
    final altas = summary['altas'] as int? ?? 0;
    final total = summary['total'] as int? ?? 0;

    final urgentes = criticas + altas;
    final porcentaje = total > 0 ? ((urgentes / total) * 100).toStringAsFixed(1) : '0';

    IconData icon;
    Color iconColor;
    Color bgColor;
    String title;
    String description;

    if (criticas > 0) {
      icon = Icons.warning_amber;
      iconColor = AppColors.critical;
      bgColor = AppColors.critical.withOpacity(0.1);
      title = 'Alertas Críticas Detectadas';
      description = '$criticas alertas críticas requieren atención inmediata.';
    } else if (altas > 0) {
      icon = Icons.error_outline;
      iconColor = AppColors.warning;
      bgColor = AppColors.warning.withOpacity(0.1);
      title = 'Alertas de Alta Prioridad';
      description = '$altas alertas altas necesitan revisión pronta.';
    } else {
      icon = Icons.check_circle_outline;
      iconColor = AppColors.success;
      bgColor = AppColors.success.withOpacity(0.1);
      title = 'Sin Alertas Urgentes';
      description = 'No hay alertas críticas o altas este mes.';
    }

    return _buildInsightCard(
      icon: icon,
      iconColor: iconColor,
      backgroundColor: bgColor,
      title: title,
      description: description,
    );
  }

  /// Insight de parámetro más afectado
  Widget _buildMostAffectedParameterInsight(Map<String, dynamic> summary) {
    final parametro = summary['parametro_mas_afectado'] as String? ?? 'ninguno';

    if (parametro == 'ninguno') {
      return const SizedBox.shrink();
    }

    return _buildInsightCard(
      icon: Icons.science_outlined,
      iconColor: AppColors.primary,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      title: 'Parámetro Más Afectado',
      description: 'El parámetro "$parametro" tiene la mayor cantidad de alertas.',
    );
  }

  /// Insight de semana crítica
  Widget _buildCriticalWeekInsight(Map<String, dynamic> summary) {
    final semanaCritica = summary['semana_critica'] as int? ?? 1;

    return _buildInsightCard(
      icon: Icons.calendar_today,
      iconColor: const Color(0xFFF59E0B),
      backgroundColor: const Color(0xFFF59E0B).withOpacity(0.1),
      title: 'Semana con Más Alertas',
      description: 'La semana $semanaCritica registró la mayor actividad de alertas.',
    );
  }

  /// Sin alertas
  Widget _buildNoAlertsInsight() {
    return _buildInsightCard(
      icon: Icons.check_circle,
      iconColor: AppColors.success,
      backgroundColor: AppColors.success.withOpacity(0.1),
      title: '¡Todo en Orden!',
      description: 'No se registraron alertas este mes. Excelente trabajo.',
    );
  }

  /// Card de insight individual
  Widget _buildInsightCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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