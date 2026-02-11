import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Leyenda de la gráfica con los colores por parámetro
class ChartLegend extends StatelessWidget {
  const ChartLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Text(
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
    );
  }

  /// Item individual de la leyenda
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
}