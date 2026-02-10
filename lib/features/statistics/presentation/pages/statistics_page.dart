import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/month_selector.dart';
import '../widgets/alerts_chart_card.dart';
import '../widgets/chart_legend.dart';
import '../widgets/summary_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../parcelas/presentation/providers/parcela_provider.dart';

/// Página principal de estadísticas de alertas
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String? _lastParcelaId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final parcelaProvider = context.read<ParcelaProvider>();
    final statsProvider = context.read<StatisticsProvider>();

    final parcelaId = parcelaProvider.parcelaSeleccionada?.id;

    if (parcelaId != null) {
      _lastParcelaId = parcelaId;
      statsProvider.loadMonthData(parcelaId);
    }
  }

  void _checkParcelaChange(String? currentParcelaId) {
    if (currentParcelaId != null && currentParcelaId != _lastParcelaId) {
      _lastParcelaId = currentParcelaId;
      context.read<StatisticsProvider>().loadMonthData(currentParcelaId);
      debugPrint('🔄 Parcela cambiada, recargando estadísticas...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StatisticsProvider, ParcelaProvider>(
      builder: (context, statsProvider, parcelaProvider, child) {
        final parcelaId = parcelaProvider.parcelaSeleccionada?.id;

        _checkParcelaChange(parcelaId);

        if (parcelaId == null) {
          return _buildNoParcelaState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await statsProvider.refresh(parcelaId);
          },
          color: AppColors.primary,
          child: Column(
            children: [
              MonthSelector(
                onMonthChanged: (month) {
                  statsProvider.loadMonthData(parcelaId);
                },
              ),

              Expanded(
                child: statsProvider.hasError
                    ? _buildErrorState(statsProvider.error!, parcelaId)
                    : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildChartSection(statsProvider),
                      const SizedBox(height: 16),
                      SummaryCard(summary: statsProvider.summary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoParcelaState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grass_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay parcela seleccionada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona una parcela desde el menú principal para ver sus estadísticas',
              textAlign: TextAlign.center,
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

  Widget _buildChartSection(StatisticsProvider statsProvider) {
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tendencia de Alertas - ${_getMonthName(statsProvider.selectedMonth)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Distribución por severidad',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'En Vivo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          AlertsChartCard(
            weeklyData: statsProvider.weeklyData,
            isLoading: statsProvider.isLoading,
          ),

          const ChartLegend(),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, String parcelaId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<StatisticsProvider>().loadMonthData(parcelaId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}