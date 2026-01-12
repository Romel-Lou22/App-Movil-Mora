import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/config/routes/app_routes.dart';
import '../providers/parcela_provider.dart';
import '../widgets/parcela_card.dart';

/// Pantalla de lista de parcelas
/// Muestra todas las parcelas activas del usuario con opciones CRUD
class ParcelasListScreen extends StatefulWidget {
  const ParcelasListScreen({super.key});

  @override
  State<ParcelasListScreen> createState() => _ParcelasListScreenState();
}

class _ParcelasListScreenState extends State<ParcelasListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar parcelas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParcelaProvider>().fetchParcelas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  /// AppBar con título y botón de cerrar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Mis Parcelas'),
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        Consumer<ParcelaProvider>(
          builder: (context, provider, child) {
            if (provider.hasParcelas) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(
                    '${provider.cantidadParcelas}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// Cuerpo principal de la pantalla
  Widget _buildBody() {
    return Consumer<ParcelaProvider>(
      builder: (context, parcelaProvider, child) {
        // Estado de loading
        if (parcelaProvider.isLoading) {
          return _buildLoadingState();
        }

        // Estado de error
        if (parcelaProvider.hasError) {
          return _buildErrorState(parcelaProvider.errorMessage);
        }

        // Estado sin parcelas
        if (!parcelaProvider.hasParcelas) {
          return _buildEmptyState();
        }

        // Estado con parcelas (lista)
        return _buildParcelasList(parcelaProvider);
      },
    );
  }

  /// Estado de carga
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando parcelas...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de error
  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar parcelas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ParcelaProvider>().fetchParcelas();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado vacío (sin parcelas)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grass_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No tienes parcelas registradas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Agrega tu primera parcela para comenzar\na monitorear tus cultivos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addParcela);
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Parcela'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lista de parcelas
  Widget _buildParcelasList(ParcelaProvider parcelaProvider) {
    return RefreshIndicator(
      onRefresh: () => parcelaProvider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 80),
        itemCount: parcelaProvider.parcelas.length,
        itemBuilder: (context, index) {
          final parcela = parcelaProvider.parcelas[index];
          final isSelected = parcelaProvider.parcelaSeleccionada?.id == parcela.id;

          return ParcelaCard(
            parcela: parcela,
            isSelected: isSelected,
            onTap: () {
              // Seleccionar esta parcela
              parcelaProvider.setParcelaSeleccionada(parcela);

              // Mostrar feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Parcela "${parcela.nombreParcela}" seleccionada'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            onEdit: () {
              // Navegar a editar parcela
              Navigator.pushNamed(
                context,
                AppRoutes.editParcela,
                arguments: parcela,
              ).then((_) {
                // Recargar parcelas al volver
                parcelaProvider.fetchParcelas();
              });
            },
            onViewData: () {
              // TODO: Navegar a ver datos históricos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ver datos históricos - En desarrollo'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Floating Action Button para agregar nueva parcela
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.addParcela).then((_) {
          // Recargar parcelas al volver
          context.read<ParcelaProvider>().fetchParcelas();
        });
      },
      icon: const Icon(Icons.add),
      label: const Text('Nueva Parcela'),
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
    );
  }
}