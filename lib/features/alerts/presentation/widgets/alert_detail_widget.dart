import 'package:flutter/material.dart';
import '../../domain/entities/alert.dart';
import 'recommendation_widget.dart';

/// Widget de detalle expandido de una alerta
///
/// Se muestra como modal/bottom sheet al hacer tap en un AlertCard
class AlertDetailWidget extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const AlertDetailWidget({
    super.key,
    required this.alert,
    this.onMarkAsRead,
    this.onDelete,
  });

  /// Muestra el detalle en un modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required Alert alert,
    VoidCallback? onMarkAsRead,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlertDetailWidget(
        alert: alert,
        onMarkAsRead: onMarkAsRead,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle del modal
          _buildHandle(),

          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con emoji y título
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // Badge de severidad y fecha
                  _buildMetadata(),

                  const SizedBox(height: 24),

                  // Información del parámetro
                  _buildParameterInfo(),

                  const SizedBox(height: 24),

                  // Ubicación
                  _buildLocationInfo(),

                  const SizedBox(height: 24),

                  // Mensaje descriptivo
                  _buildMessage(),

                  const SizedBox(height: 24),

                  // Recomendación
                  if (alert.recomendacion != null &&
                      alert.recomendacion!.isNotEmpty)
                    _buildRecommendation(),

                  if (alert.recomendacion != null &&
                      alert.recomendacion!.isNotEmpty)
                    const SizedBox(height: 24),

                  // Detalles técnicos
                  _buildTechnicalDetails(),

                  const SizedBox(height: 32),

                  // Botones de acción
                  _buildActionButtons(context),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle visual del modal
  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Header con emoji y título
  Widget _buildHeader() {
    return Row(
      children: [
        // Emoji
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _getSeverityColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              alert.emoji,
              style: const TextStyle(fontSize: 36),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Título
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getAlertTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                alert.parametro,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Metadata: Severidad y fecha
  Widget _buildMetadata() {
    return Row(
      children: [
        // Badge de severidad
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getSeverityColor(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            alert.severidad?.toUpperCase() ?? 'ALERTA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Fecha
        Icon(
          Icons.calendar_today,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Text(
          _formatDate(alert.fechaAlerta),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),

        const Spacer(),

        // Estado (vista/no vista)
        if (!alert.vista)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 6),
                Text(
                  'NO LEÍDA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Información del parámetro medido
  Widget _buildParameterInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Valor detectado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Valor Detectado',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${alert.valorDetectado.toStringAsFixed(1)} ${_getUnit()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _getSeverityColor(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Umbral óptimo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rango Óptimo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                alert.umbral,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Información de ubicación
  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.blue[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UBICACIÓN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // TODO: Reemplazar con nombre de parcela real
                  'Tisaleo, Ecuador',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mensaje descriptivo
  Widget _buildMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DESCRIPCIÓN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          alert.mensaje,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Widget de recomendación
  Widget _buildRecommendation() {
    if (alert.severidad?.toLowerCase() == 'critica') {
      return CriticalRecommendationWidget(
        recommendation: alert.recomendacion!,
      );
    } else if (alert.severidad?.toLowerCase() == 'alta' ||
        alert.severidad?.toLowerCase() == 'preventiva') {
      return WarningRecommendationWidget(
        recommendation: alert.recomendacion!,
      );
    } else {
      return RecommendationWidget(
        recommendation: alert.recomendacion!,
      );
    }
  }

  /// Detalles técnicos adicionales
  Widget _buildTechnicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DETALLES TÉCNICOS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),

        _buildDetailRow('Tipo de Alerta', alert.tipoAlerta),
        _buildDetailRow('ID', alert.id.substring(0, 8) + '...'),
        _buildDetailRow('Fecha de Creación', _formatDateTime(alert.createdAt)),
        if (alert.isActive)
          _buildDetailRow('Estado', 'Activa', color: Colors.green)
        else
          _buildDetailRow('Estado', 'Expirada', color: Colors.grey),
      ],
    );
  }

  /// Fila de detalle técnico
  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Botones de acción
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Botón marcar como vista
        if (!alert.vista && onMarkAsRead != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                onMarkAsRead?.call();
                Navigator.of(context).pop();
              },
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        if (!alert.vista && onMarkAsRead != null)
          const SizedBox(height: 12),

        // Botón eliminar
        if (onDelete != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                _showDeleteConfirmation(context);
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text(
                'ELIMINAR ALERTA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700],
                side: BorderSide(color: Colors.red[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Muestra confirmación para eliminar
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Alerta'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta alerta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Cerrar bottom sheet
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ========== HELPERS ==========

  Color _getSeverityColor() {
    if (alert.severidad == null) return Colors.grey;

    switch (alert.severidad!.toLowerCase()) {
      case 'critica':
        return const Color(0xFFDC2626);
      case 'alta':
      case 'preventiva':
        return const Color(0xFFF59E0B);
      case 'media':
        return const Color(0xFFFCD34D);
      case 'baja':
      case 'normal':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  String _getAlertTitle() {
    final titles = {
      'helada': 'Riesgo de Helada',
      'temp_baja': 'Temperatura Baja',
      'temp_alta': 'Temperatura Alta',
      'sequia': 'Riesgo de Sequía',
      'hum_baja': 'Humedad Baja',
      'hum_alta': 'Humedad Alta',
      'ph_bajo': 'pH Bajo',
      'ph_alto': 'pH Alto',
      'n_bajo': 'Nitrógeno Bajo',
      'n_alto': 'Nitrógeno Alto',
      'p_bajo': 'Fósforo Bajo',
      'p_alto': 'Fósforo Alto',
      'k_bajo': 'Potasio Bajo',
      'k_alto': 'Potasio Alto',
    };

    return titles[alert.tipoAlerta] ?? 'Alerta';
  }

  String _getUnit() {
    if (alert.tipoAlerta.contains('ph')) return 'pH';
    if (alert.tipoAlerta.contains('temp')) return '°C';
    if (alert.tipoAlerta.contains('hum')) return '%';
    if (alert.tipoAlerta.contains('_')) return 'ppm';
    return '';
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}