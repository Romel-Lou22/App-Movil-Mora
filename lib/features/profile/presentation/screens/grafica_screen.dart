import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

/// Pantalla de predicciones semanales/mensuales
/// Muestra tendencias de N, P, K, pH, Humedad y Temperatura
class GraficaScreen extends StatefulWidget {
  const GraficaScreen({Key? key}) : super(key: key);

  @override
  State<GraficaScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<GraficaScreen> {
  int _selectedMonthIndex = 0;
  final List<String> _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildMonthTabs(),
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
                    _buildPredictionCard(),
                    const SizedBox(height: 16),
                    _buildKeyInsights(),
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

  /// Simula refresco de datos
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Aquí cargarías datos reales del provider
    });
  }

  /// App Bar con flecha de regreso
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Predicciones Semanales',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white),
              // Badge de notificaciones (opcional)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            // TODO: Ir a alertas
            Navigator.pushNamed(context, '/alerts');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Tabs de meses con scroll horizontal
  Widget _buildMonthTabs() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: List.generate(_months.length, (index) {
            final isSelected = index == _selectedMonthIndex;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMonthIndex = index;
                });
                // TODO: Cargar datos del mes seleccionado
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 24),
                padding: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _months[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Card principal con gráfica
  Widget _buildPredictionCard() {
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tendencias del Suelo y Ambiente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Análisis mensual en porcentajes',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'En Vivo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Gráfica
          Container(
            height: 320,
            padding: const EdgeInsets.all(16),
            child: _buildMultiLineChart(),
          ),

          // Leyenda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LEYENDA DE PARÁMETROS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildLegendItem('N (Nitrógeno)', const Color(0xFF7B2869)),
                          const SizedBox(height: 8),
                          _buildLegendItem('pH (Acidez)', const Color(0xFFF59E0B)),
                          const SizedBox(height: 8),
                          _buildLegendItem('Humedad', const Color(0xFF0EA5E9)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _buildLegendItem('K (Potasio)', const Color(0xFF10B981)),
                          const SizedBox(height: 8),
                          _buildLegendItem('P (Fósforo)', const Color(0xFFEF4444)),
                          const SizedBox(height: 8),
                          _buildLegendItem('Temperatura', const Color(0xFF06B6D4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Item de leyenda con animación
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Gráfica de líneas múltiples mejorada
  Widget _buildMultiLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const weeks = ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'];
                if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      weeks[value.toInt()],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: 3,
        minY: 0,
        maxY: 100,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.9), // ✅ Nuevo parámetro
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  '${barSpot.y.toInt()}%',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          // N (Nitrogen) - Morado
          _createLineChartBarData(
            const Color(0xFF7B2869),
            [
              const FlSpot(0, 27),
              const FlSpot(1, 33),
              const FlSpot(2, 50),
              const FlSpot(3, 60),
            ],
          ),
          // K (Potassium) - Verde
          _createLineChartBarData(
            const Color(0xFF10B981),
            [
              const FlSpot(0, 17),
              const FlSpot(1, 30),
              const FlSpot(2, 27),
              const FlSpot(3, 47),
            ],
          ),
          // pH - Naranja
          _createLineChartBarData(
            const Color(0xFFF59E0B),
            [
              const FlSpot(0, 50),
              const FlSpot(1, 47),
              const FlSpot(2, 57),
              const FlSpot(3, 53),
            ],
          ),
          // P (Phosphorus) - Rojo
          _createLineChartBarData(
            const Color(0xFFEF4444),
            [
              const FlSpot(0, 7),
              const FlSpot(1, 13),
              const FlSpot(2, 20),
              const FlSpot(3, 23),
            ],
          ),
          // Humidity - Azul claro
          _createLineChartBarData(
            const Color(0xFF0EA5E9),
            [
              const FlSpot(0, 67),
              const FlSpot(1, 80),
              const FlSpot(2, 70),
              const FlSpot(3, 87),
            ],
          ),
          // Temperature - Cyan
          _createLineChartBarData(
            const Color(0xFF06B6D4),
            [
              const FlSpot(0, 60),
              const FlSpot(1, 63),
              const FlSpot(2, 67),
              const FlSpot(3, 73),
            ],
          ),
        ],
      ),
    );
  }

  /// Crear línea para la gráfica con sombra
  LineChartBarData _createLineChartBarData(Color color, List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
      shadow: Shadow(
        color: color.withOpacity(0.3),
        blurRadius: 4,
      ),
    );
  }

  /// Insights clave de la semana
  Widget _buildKeyInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Análisis Clave - Semana 4',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _buildInsightCard(
          icon: Icons.trending_up,
          iconColor: Colors.green,
          backgroundColor: Colors.green.shade50,
          title: 'Nivel de pH Óptimo',
          description: 'Estabilizado en 6.8 esta semana.',
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          icon: Icons.water_drop,
          iconColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
          title: 'Incremento de Humedad',
          description: 'Proyección de aumento del 15% próximos días.',
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          icon: Icons.eco,
          iconColor: Colors.purple,
          backgroundColor: Colors.purple.shade50,
          title: 'Nitrógeno en Aumento',
          description: 'Tendencia positiva de +10% respecto a la semana anterior.',
        ),
      ],
    );
  }

  /// Card de insight individual mejorado
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
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}