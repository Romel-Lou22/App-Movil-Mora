import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

/// Gráfica de líneas múltiples para mostrar tendencias de parámetros
class MultiLineChart extends StatelessWidget {
  final Map<String, Map<String, double>> weeklyData;

  const MultiLineChart({
    Key? key,
    required this.weeklyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.9),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final paramName = _getParamNameByIndex(barSpot.barIndex);
                return LineTooltipItem(
                  '$paramName\n${barSpot.y.toStringAsFixed(1)}%',
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
        lineBarsData: _buildLineBarsData(),
      ),
    );
  }

  /// Construir las 6 líneas con datos reales
  List<LineChartBarData> _buildLineBarsData() {
    return [
      // N (Nitrógeno) - Morado
      _createLineChartBarData(
        const Color(0xFF7B2869),
        _getParameterSpots('nitrogeno'),
      ),
      // K (Potasio) - Verde
      _createLineChartBarData(
        const Color(0xFF10B981),
        _getParameterSpots('potasio'),
      ),
      // pH - Naranja
      _createLineChartBarData(
        const Color(0xFFF59E0B),
        _getParameterSpots('ph'),
      ),
      // P (Fósforo) - Rojo
      _createLineChartBarData(
        const Color(0xFFEF4444),
        _getParameterSpots('fosforo'),
      ),
      // Humedad - Azul claro
      _createLineChartBarData(
        const Color(0xFF0EA5E9),
        _getParameterSpots('humedad'),
      ),
      // Temperatura - Cyan
      _createLineChartBarData(
        const Color(0xFF06B6D4),
        _getParameterSpots('temperatura'),
      ),
    ];
  }

  /// Obtener los puntos (spots) para un parámetro específico
  List<FlSpot> _getParameterSpots(String parameter) {
    final spots = <FlSpot>[];

    for (int week = 1; week <= 4; week++) {
      final weekKey = 'semana_$week';
      final weekData = weeklyData[weekKey];

      if (weekData != null && weekData.containsKey(parameter)) {
        final percentage = weekData[parameter] ?? 0.0;
        // week 1-4 → index 0-3
        spots.add(FlSpot((week - 1).toDouble(), percentage));
      } else {
        // Si no hay datos, punto en 0
        spots.add(FlSpot((week - 1).toDouble(), 0.0));
      }
    }

    return spots;
  }

  /// Crear configuración de línea
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

  /// Obtener nombre del parámetro por índice (para tooltip)
  String _getParamNameByIndex(int index) {
    switch (index) {
      case 0:
        return 'Nitrógeno';
      case 1:
        return 'Potasio';
      case 2:
        return 'pH';
      case 3:
        return 'Fósforo';
      case 4:
        return 'Humedad';
      case 5:
        return 'Temperatura';
      default:
        return 'Desconocido';
    }
  }
}