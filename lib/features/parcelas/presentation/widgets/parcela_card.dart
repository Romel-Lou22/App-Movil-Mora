import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/parcela.dart';

/// Widget que muestra una parcela en formato card
/// Usado en la lista de parcelas (parcelas_list_screen)
class ParcelaCard extends StatelessWidget {
  final Parcela parcela;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onViewData;
  final bool isSelected;

  const ParcelaCard({
    super.key,
    required this.parcela,
    this.onTap,
    this.onEdit,
    this.onViewData,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nombre + indicador de seleccionada
              _buildHeader(),

              const SizedBox(height: 12),

              // Ubicación
              _buildUbicacion(),

              const SizedBox(height: 8),

              // Área (si está disponible)
              if (parcela.areaHectareas != null) ...[
                _buildArea(),
                const SizedBox(height: 12),
              ] else
                const SizedBox(height: 12),

              // Botones de acción
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header con nombre y estado de selección
  Widget _buildHeader() {
    return Row(
      children: [
        // Icono de parcela
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.grass,
            color: AppColors.primary,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        // Nombre de la parcela
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parcela.nombreParcela,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Seleccionada',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Indicador visual si está seleccionada
        if (isSelected)
          const Icon(
            Icons.check_circle,
            color: AppColors.primary,
            size: 24,
          ),
      ],
    );
  }

  /// Widget de ubicación
  Widget _buildUbicacion() {
    return Row(
      children: [
        const Icon(
          Icons.location_on,
          color: AppColors.iconSecondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            parcela.ubicacionDisplay,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Widget de área
  Widget _buildArea() {
    return Row(
      children: [
        const Icon(
          Icons.square_foot,
          color: AppColors.iconSecondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Área: ${parcela.areaDisplay}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Botones de acción
  Widget _buildActions() {
    return Row(
      children: [
        // Botón "VER DATOS"
        if (onViewData != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onViewData,
              icon: const Icon(Icons.bar_chart, size: 18),
              label: const Text('VER DATOS'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

        if (onViewData != null && onEdit != null) const SizedBox(width: 12),

        // Botón "EDITAR"
        if (onEdit != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('EDITAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }
}