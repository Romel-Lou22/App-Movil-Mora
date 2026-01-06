import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Widget que muestra una tarjeta de estado normal/óptimo
///
/// Características:
/// - Diseño positivo y tranquilizador
/// - Icono verde de estado OK
/// - Mensaje de confirmación
/// - Sin acciones (solo informativo)
class AlertNormalCard extends StatelessWidget {
  /// Título de la tarjeta (ej: "Todo en orden")
  final String title;

  /// Descripción de los parámetros óptimos
  final String description;

  /// Lista de parámetros en estado óptimo (opcional)
  final List<String>? optimalParameters;

  /// Callback cuando se toca la tarjeta (opcional)
  final VoidCallback? onTap;

  const AlertNormalCard({
    Key? key,
    this.title = 'Todo en orden',
    required this.description,
    this.optimalParameters,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de estado OK
            _buildIcon(),
            const SizedBox(width: 16),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título con check
                  _buildTitle(),
                  const SizedBox(height: 8),

                  // Descripción
                  _buildDescription(),

                  // Lista de parámetros óptimos (si existe)
                  if (optimalParameters != null && optimalParameters!.isNotEmpty)
                    _buildParametersList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el icono de estado normal
  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.eco,
        size: 32,
        color: AppColors.success,
      ),
    );
  }

  /// Construye el título con check
  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.check,
            size: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Construye la descripción
  Widget _buildDescription() {
    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  /// Construye la lista de parámetros óptimos
  Widget _buildParametersList() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: optimalParameters!.map((param) => _buildParameterChip(param)).toList(),
      ),
    );
  }

  /// Chip individual de parámetro
  Widget _buildParameterChip(String parameter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 14,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            parameter,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget compacto para mostrar estado normal en listas
class CompactNormalCard extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const CompactNormalCard({
    Key? key,
    this.message = 'Todos los parámetros están en rango óptimo',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.success.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 20,
              color: AppColors.success,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar resumen de estado normal con estadísticas
class NormalStateSummaryCard extends StatelessWidget {
  /// Cantidad de lotes en estado óptimo
  final int optimalLotesCount;

  /// Total de lotes monitoreados
  final int totalLotes;

  /// Parámetros monitoreados
  final List<String> monitoredParameters;

  /// Callback al tocar
  final VoidCallback? onTap;

  const NormalStateSummaryCard({
    Key? key,
    required this.optimalLotesCount,
    required this.totalLotes,
    required this.monitoredParameters,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = totalLotes > 0
        ? ((optimalLotesCount / totalLotes) * 100).toStringAsFixed(0)
        : '0';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withOpacity(0.1),
              AppColors.success.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.success.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono y título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estado Óptimo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        '$optimalLotesCount de $totalLotes lotes',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Porcentaje
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Parámetros monitoreados
            Text(
              'Parámetros en rango óptimo:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: monitoredParameters
                  .map((param) => _buildParameterBadge(param))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterBadge(String parameter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        parameter,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.success,
        ),
      ),
    );
  }
}