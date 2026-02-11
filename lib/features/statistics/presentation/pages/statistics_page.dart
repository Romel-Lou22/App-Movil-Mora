import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';

import '../../../parcelas/presentation/providers/parcela_provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/month_selector.dart';
import '../widgets/alerts_chart_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/insights_section.dart';

/// Página de estadísticas y gráficas de alertas
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Cargar datos de la parcela activa
  void _loadData() {
    final parcelasProvider = context.read<ParcelaProvider>();
    final statsProvider = context.read<StatisticsProvider>();

    final parcelaActiva = parcelasProvider.parcelaSeleccionada;

    if (parcelaActiva != null) {
      statsProvider.loadMonthData(parcelaActiva.id);
    } else {
      // Si no hay parcela activa, mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay parcela activa seleccionada'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  /// Refrescar datos
  Future<void> _refreshData() async {
    final parcelasProvider = context.read<ParcelaProvider>();
    final statsProvider = context.read<StatisticsProvider>();

    final parcelaActiva = parcelasProvider.parcelaSeleccionada;

    if (parcelaActiva != null) {
      await statsProvider.refresh(parcelaActiva.id);
    }
  }

  /// Cambiar mes seleccionado
  void _onMonthChanged(int month) {
    final parcelasProvider = context.read<ParcelaProvider>();
    final statsProvider = context.read<StatisticsProvider>();

    final parcelaActiva = parcelasProvider.parcelaSeleccionada;

    if (parcelaActiva != null) {
      statsProvider.loadMonthData(parcelaActiva.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
     
      body: Column(
        children: [
          // Selector de meses
          MonthSelector(
            onMonthChanged: _onMonthChanged,
          ),

          // Contenido con scroll
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gráfica principal
                    const AlertsChartCard(),

                    const SizedBox(height: 16),

                    // Resumen del mes
                    Consumer<StatisticsProvider>(
                      builder: (context, provider, child) {
                        if (provider.hasData && provider.summary.isNotEmpty) {
                          return SummaryCard(summary: provider.summary);
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 16),

                    // Análisis clave (opcional)
                    const InsightsSection(),

                    const SizedBox(height: 80), // Espacio para el bottom nav
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// Diálogo de información
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre las Estadísticas'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta gráfica muestra el porcentaje de alertas por parámetro durante cada semana del mes.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'Parámetros monitoreados:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Nitrógeno (N)'),
              Text('• Fósforo (P)'),
              Text('• Potasio (K)'),
              Text('• pH (Acidez)'),
              Text('• Humedad del Suelo'),
              Text('• Temperatura'),
              SizedBox(height: 12),
              Text(
                'El porcentaje se calcula sobre el total de alertas del mes seleccionado.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}