import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../../domain/entities/parcela.dart';
import '../providers/parcela_provider.dart';

/// Dropdown selector de parcelas para el AppBar del HomeScreen
/// Muestra la parcela seleccionada y permite cambiarla
class ParcelaSelectorDropdown extends StatelessWidget {
  const ParcelaSelectorDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ParcelaProvider>(
      builder: (context, parcelaProvider, child) {
        // Si no hay parcelas, mostrar mensaje
        if (!parcelaProvider.hasParcelas) {
          return _buildSinParcelas(context);
        }

        final parcelaSeleccionada = parcelaProvider.parcelaSeleccionada;
        final parcelas = parcelaProvider.parcelas;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: parcelaSeleccionada?.id,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              dropdownColor: AppColors.secondary,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              isDense: true,
              items: [
                // Items de parcelas
                ...parcelas.map((parcela) => _buildParcelaItem(parcela)),

                // Divider
                const DropdownMenuItem<String>(
                  enabled: false,
                  value: null,
                  child: Divider(color: Colors.white30, height: 1),
                ),

                // Opción: Agregar nueva parcela
                _buildAddParcelaItem(),

                // Opción: Gestionar todas
                _buildManageAllItem(),
              ],
              onChanged: (String? value) {
                if (value == null) return;

                if (value == 'add_new') {
                  // Navegar a agregar nueva parcela
                  Navigator.pushNamed(context, AppRoutes.addParcela);
                } else if (value == 'manage_all') {
                  // Navegar a gestionar todas las parcelas
                  Navigator.pushNamed(context, AppRoutes.parcelas);
                } else {
                  // Cambiar la parcela seleccionada
                  parcelaProvider.setParcelaSeleccionadaById(value);
                }
              },
            ),
          ),
        );
      },
    );
  }

  /// Widget cuando no hay parcelas
  Widget _buildSinParcelas(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.addParcela);
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Agregar Parcela',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Item de una parcela en el dropdown
  DropdownMenuItem<String> _buildParcelaItem(Parcela parcela) {
    return DropdownMenuItem<String>(
      value: parcela.id,
      child: Row(
        children: [
          // Icono de parcela
          const Icon(
            Icons.grass,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),

          // Información de la parcela
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre
                Text(
                  parcela.nombreParcela,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Ubicación
                Text(
                  '📍 ${parcela.ubicacionDisplay}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Item "Agregar nueva parcela"
  DropdownMenuItem<String> _buildAddParcelaItem() {
    return const DropdownMenuItem<String>(
      value: 'add_new',
      child: Row(
        children: [
          Icon(
            Icons.add_circle_outline,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            'Agregar nueva parcela',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Item "Gestionar todas"
  DropdownMenuItem<String> _buildManageAllItem() {
    return const DropdownMenuItem<String>(
      value: 'manage_all',
      child: Row(
        children: [
          Icon(
            Icons.settings,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 12),
          Text(
            'Gestionar todas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}