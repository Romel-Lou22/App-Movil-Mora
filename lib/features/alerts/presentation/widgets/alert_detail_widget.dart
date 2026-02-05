import 'package:flutter/material.dart';
import '../../domain/entities/alert.dart';
import 'recommendation_widget.dart';

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
          _buildHandle(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildMetadata(),
                  const SizedBox(height: 24),
                  _buildParameterInfo(),
                  const SizedBox(height: 24),
                  _buildLocationInfo(),
                  const SizedBox(height: 24),
                  _buildMessage(),
                  const SizedBox(height: 24),
                  if ((alert.recomendacion ?? '').trim().isNotEmpty) ...[
                    _buildRecommendation(),
                    const SizedBox(height: 24),
                  ],
                  _buildTechnicalDetails(),
                  const SizedBox(height: 32),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _severityColor(alert.severidad).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              _emojiForType(alert.tipoAlerta),
              style: const TextStyle(fontSize: 36),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _titleForType(alert.tipoAlerta),
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

  Widget _buildMetadata() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _severityColor(alert.severidad),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _severityLabel(alert.severidad),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
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
                Icon(Icons.circle, size: 8, color: Colors.orange[700]),
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

  Widget _buildParameterInfo() {
    final unit = _unitForType(alert.tipoAlerta);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
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
                '${alert.valorDetectado.toStringAsFixed(1)} $unit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _severityColor(alert.severidad),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue[700], size: 24),
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

  Widget _buildRecommendation() {
    final rec = alert.recomendacion!.trim();

    switch (alert.severidad) {
      case AlertSeverity.critica:
        return CriticalRecommendationWidget(recommendation: rec);
      case AlertSeverity.alta:
        return WarningRecommendationWidget(recommendation: rec);
      case AlertSeverity.media:
      case AlertSeverity.baja:
      case null:
        return RecommendationWidget(recommendation: rec);
    }
  }

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
        _buildDetailRow('Tipo de Alerta', _dbValueForType(alert.tipoAlerta)),
        _buildDetailRow('ID', alert.id.length > 8 ? '${alert.id.substring(0, 8)}...' : alert.id),
        _buildDetailRow('Fecha de Creación', _formatDateTime(alert.createdAt)),
        _buildDetailRow(
          'Estado',
          alert.isActive ? 'Activa' : 'Expirada',
          color: alert.isActive ? Colors.green : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (!alert.vista && onMarkAsRead != null) const SizedBox(height: 12),
        if (onDelete != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
      ],
    );
  }

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
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ===================== HELPERS (ENUM-SAFE) =====================

  String _severityLabel(AlertSeverity? s) {
    switch (s) {
      case AlertSeverity.critica:
        return 'CRÍTICA';
      case AlertSeverity.alta:
        return 'ALTA';
      case AlertSeverity.media:
        return 'MEDIA';
      case AlertSeverity.baja:
        return 'BAJA';
      case null:
        return 'ALERTA';
    }
  }

  Color _severityColor(AlertSeverity? s) {
    switch (s) {
      case AlertSeverity.critica:
        return const Color(0xFFDC2626);
      case AlertSeverity.alta:
        return const Color(0xFFF59E0B);
      case AlertSeverity.media:
        return const Color(0xFFFCD34D);
      case AlertSeverity.baja:
        return const Color(0xFF10B981);
      case null:
        return Colors.grey;
    }
  }

  String _titleForType(AlertType type) {
    switch (type) {
      case AlertType.phBajo:
        return 'Riesgo de pH Bajo';
      case AlertType.phAlto:
        return 'Riesgo de pH Alto';
      case AlertType.humBaja:
        return 'Humedad Baja';
      case AlertType.humAlta:
        return 'Humedad Alta';
      case AlertType.tempBaja:
        return 'Temperatura Baja';
      case AlertType.tempAlta:
        return 'Temperatura Alta';
      case AlertType.nBajo:
        return 'Nitrógeno Bajo';
      case AlertType.nAlto:
        return 'Nitrógeno Alto';
      case AlertType.pBajo:
        return 'Fósforo Bajo';
      case AlertType.pAlto:
        return 'Fósforo Alto';
      case AlertType.kBajo:
        return 'Potasio Bajo';
      case AlertType.kAlto:
        return 'Potasio Alto';
    }
  }

  String _emojiForType(AlertType type) {
    switch (type) {
      case AlertType.phBajo:
      case AlertType.phAlto:
        return '🧪';
      case AlertType.humBaja:
        return '🌵';
      case AlertType.humAlta:
        return '💧';
      case AlertType.tempBaja:
        return '❄️';
      case AlertType.tempAlta:
        return '🔥';
      case AlertType.nBajo:
        return '🌿';
      case AlertType.nAlto:
        return '⚠️';
      case AlertType.pBajo:
        return '🧬';
      case AlertType.pAlto:
        return '⚗️';
      case AlertType.kBajo:
        return '🍃';
      case AlertType.kAlto:
        return '⚡';
    }
  }

  /// Texto “dbValue” para UI técnica (ej: ph_bajo, temp_alta, etc.).
  /// Si ya tienes un getter tipo `AlertType.dbValue`, úsalo aquí y elimina este switch.
  String _dbValueForType(AlertType type) {
    switch (type) {
      case AlertType.phBajo:
        return 'ph_bajo';
      case AlertType.phAlto:
        return 'ph_alto';
      case AlertType.humBaja:
        return 'hum_baja';
      case AlertType.humAlta:
        return 'hum_alta';
      case AlertType.tempBaja:
        return 'temp_baja';
      case AlertType.tempAlta:
        return 'temp_alta';
      case AlertType.nBajo:
        return 'n_bajo';
      case AlertType.nAlto:
        return 'n_alto';
      case AlertType.pBajo:
        return 'p_bajo';
      case AlertType.pAlto:
        return 'p_alto';
      case AlertType.kBajo:
        return 'k_bajo';
      case AlertType.kAlto:
        return 'k_alto';
    }
  }

  String _unitForType(AlertType type) {
    switch (type) {
      case AlertType.phBajo:
      case AlertType.phAlto:
        return 'pH';
      case AlertType.tempBaja:
      case AlertType.tempAlta:
        return '°C';
      case AlertType.humBaja:
      case AlertType.humAlta:
        return '%';
      case AlertType.nBajo:
      case AlertType.nAlto:
      case AlertType.pBajo:
      case AlertType.pAlto:
      case AlertType.kBajo:
      case AlertType.kAlto:
        return 'ppm';
    }
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
