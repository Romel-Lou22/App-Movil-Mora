import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

class AlertsChartCard extends StatelessWidget {
  final Map<String, Map<String, int>> weeklyData;
  final bool isLoading;

  const AlertsChartCard({
    super.key,
    required this.weeklyData,
    this.isLoading = false,
  });

  static const Color _criticaColor = Color(0xFFDC2626);
  static const Color _altaColor = Color(0xFFF59E0B);
  static const Color _mediaColor = Color(0xFFFBBF24);
  static const Color _bajaColor = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(Icons.show_chart, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Alertas por Semana',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 260,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : weeklyData.isEmpty
                ? _buildEmptyState()
                : _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            'No hay datos para este mes',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 16, top: 8),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 3,
          minY: 0,
          maxY: _calculateMaxY(),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateYInterval(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),

          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: _bottomTitleWidgets,
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'N° de alertas',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              axisNameSize: 24,
              sideTitles: SideTitles(
                showTitles: true,
                interval: _calculateYInterval(),
                reservedSize: 36,
                getTitlesWidget: _leftTitleWidgets,
              ),
            ),
          ),

          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),

          lineBarsData: [
            _buildLineChartBarData('critica', _criticaColor),
            _buildLineChartBarData('alta', _altaColor),
            _buildLineChartBarData('media', _mediaColor),
            _buildLineChartBarData('baja', _bajaColor),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(String severidad, Color color) {
    return LineChartBarData(
      spots: _getDataPoints(severidad),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }

  List<FlSpot> _getDataPoints(String severidad) {
    return List.generate(4, (i) {
      final key = 'semana_${i + 1}';
      final value = weeklyData[key]?[severidad] ?? 0;
      return FlSpot(i.toDouble(), value.toDouble());
    });
  }

  double _calculateMaxY() {
    double maxValue = 0;
    for (final severities in weeklyData.values) {
      for (final count in severities.values) {
        if (count > maxValue) maxValue = count.toDouble();
      }
    }
    final maxY = (maxValue * 1.2).ceilToDouble();
    return maxY < 4 ? 4 : maxY;
  }

  double _calculateYInterval() {
    final maxY = _calculateMaxY();
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    return 10;
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const labels = ['S1', 'S2', 'S3', 'S4'];
    if (value.toInt() < 0 || value.toInt() > 3) return const SizedBox();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        labels[value.toInt()],
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    if (value % 1 != 0) return const SizedBox();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
