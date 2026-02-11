import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/statistics_provider.dart';
import 'multi_line_chart.dart';
import 'chart_legend.dart';

/// Card principal que contiene la gráfica de alertas
class AlertsChartCard extends StatelessWidget {
  const AlertsChartCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingCard();
        }

        if (provider.hasError) {
          return _buildErrorCard(provider.error!);
        }

        if (!provider.hasData) {
          return _buildEmptyCard();
        }

        return _buildChartCard(provider);
      },
    );
  }

  /// Card con la gráfica completa
  Widget _buildChartCard(StatisticsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(provider),

          // Gráfica
          Container(
            height: 320,
            padding: const EdgeInsets.all(16),
            child: MultiLineChart(
              weeklyData: provider.weeklyData,
            ),
          ),

          // Leyenda
          const ChartLegend(),
        ],
      ),
    );
  }

  /// Header del card
  Widget _buildHeader(StatisticsProvider provider) {
    final monthName = _getMonthName(provider.selectedMonth);
    final totalAlertas = provider.summary['total'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tendencias de Alertas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Distribución por parámetro - $monthName',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: totalAlertas > 0
                  ? AppColors.warning.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  totalAlertas > 0 ? Icons.warning_amber : Icons.check_circle,
                  size: 12,
                  color: totalAlertas > 0 ? AppColors.warning : AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  '$totalAlertas alertas',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: totalAlertas > 0 ? AppColors.warning : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card de carga
  Widget _buildLoadingCard() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Cargando estadísticas...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de error
  Widget _buildErrorCard(String error) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar datos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card sin datos
  Widget _buildEmptyCard() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay datos disponibles',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron alertas para este período',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obtener nombre del mes
  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}