import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Card de resumen del mes
class SummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;

  const SummaryCard({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = summary['total'] as int? ?? 0;
    final criticas = summary['criticas'] as int? ?? 0;
    final altas = summary['altas'] as int? ?? 0;
    final medias = summary['medias'] as int? ?? 0;
    final bajas = summary['bajas'] as int? ?? 0;
    final tipoMasFrecuente = summary['tipo_mas_frecuente'] as String? ?? 'ninguno';
    final semanaCritica = summary['semana_critica'] as int? ?? 1;

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
              Icon(
                Icons.assessment_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Resumen del Mes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Total de alertas
          _buildSummaryRow(
            'Total de alertas:',
            total.toString(),
            total > 0 ? const Color(0xFFF59E0B) : Colors.grey,
          ),
          const SizedBox(height: 8),

          // Alertas críticas
          _buildSummaryRow(
            'Alertas críticas:',
            criticas.toString(),
            criticas > 0 ? const Color(0xFFDC2626) : Colors.grey,
          ),
          const SizedBox(height: 8),

          // Alertas altas
          _buildSummaryRow(
            'Alertas altas:',
            altas.toString(),
            altas > 0 ? const Color(0xFFF59E0B) : Colors.grey,
          ),
          const SizedBox(height: 8),

          // Tipo más frecuente
          _buildSummaryRow(
            'Tipo más frecuente:',
            _formatTipoAlerta(tipoMasFrecuente),
            AppColors.primary,
          ),
          const SizedBox(height: 8),

          // Semana crítica
          _buildSummaryRow(
            'Semana crítica:',
            'Semana $semanaCritica',
            const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }

  /// Fila de resumen
  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Formatear nombre del tipo de alerta
  String _formatTipoAlerta(String tipo) {
    if (tipo == 'ninguno') return 'Ninguno';

    // Capitalizar primera letra
    return tipo.substring(0, 1).toUpperCase() + tipo.substring(1).toLowerCase();
  }
}