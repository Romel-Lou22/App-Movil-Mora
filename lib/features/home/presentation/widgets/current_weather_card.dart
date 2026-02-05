// lib/features/weather/presentation/widgets/current_weather_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../parcelas/presentation/providers/parcela_provider.dart';
import '../../../weather/presentation/providers/weather_provider.dart';

class CurrentWeatherCard extends StatefulWidget {
  const CurrentWeatherCard({super.key});

  @override
  State<CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard> {
  String? _lastParcelaId;

  @override
  void initState() {
    super.initState();

    // 1) Escuchar cambios del provider de parcelas (cambio de selección)
    context.read<ParcelaProvider>().addListener(_onParcelaChanged);

    // 2) Cargar al iniciar si ya hay parcela seleccionada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchUsingSelectedParcela();
    });
  }

  @override
  void dispose() {
    // Importante: remover listener
    context.read<ParcelaProvider>().removeListener(_onParcelaChanged);
    super.dispose();
  }

  void _onParcelaChanged() {
    if (!mounted) return;

    final parcela = context.read<ParcelaProvider>().parcelaSeleccionada;
    final id = parcela?.id;

    if (parcela == null || parcela.isEmpty) return;
    if (id == null || id.isEmpty) return;
    if (id == _lastParcelaId) return;

    _lastParcelaId = id;

    context.read<WeatherProvider>().fetchCurrentWeather(
      lat: parcela.latitudEfectiva,
      lon: parcela.longitudEfectiva,
    );
  }

  void _fetchUsingSelectedParcela() {
    final parcela = context.read<ParcelaProvider>().parcelaSeleccionada;
    if (parcela == null || parcela.isEmpty) return;

    _lastParcelaId = parcela.id;

    context.read<WeatherProvider>().fetchCurrentWeather(
      lat: parcela.latitudEfectiva,
      lon: parcela.longitudEfectiva,
    );
  }

  void _refreshForCurrentParcela() {
    final parcela = context.read<ParcelaProvider>().parcelaSeleccionada;
    if (parcela == null || parcela.isEmpty) return;

    context.read<WeatherProvider>().refresh(
      lat: parcela.latitudEfectiva,
      lon: parcela.longitudEfectiva,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ParcelaProvider, WeatherProvider>(
      builder: (context, parcelaProvider, weatherProvider, child) {
        final parcela = parcelaProvider.parcelaSeleccionada;

        // Sin parcela seleccionada
        if (parcela == null || parcela.isEmpty) {
          return _buildContainer(
            child: const Text('Selecciona una parcela para ver el clima.'),
          );
        }

        // Cargando
        if (weatherProvider.isLoading) {
          return _buildContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        // Error
        if (weatherProvider.hasError) {
          return _buildContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Text(
                  'Error: ${weatherProvider.errorMessage}',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _refreshForCurrentParcela,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ),
              ],
            ),
          );
        }

        // Datos cargados
        final weather = weatherProvider.weather;
        if (weather == null) {
          return _buildContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                const Text('No hay datos disponibles.'),
              ],
            ),
          );
        }

        return _buildContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),

              // Contenido principal
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icono clima (más pequeño: 48x48)
                  Image.network(
                    weather.iconUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.wb_cloudy_outlined,
                        size: 48,
                        color: AppColors.textSecondary.withOpacity(0.6),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  // Descripción + humedad (Expanded para evitar overflow)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.descriptionCapitalized,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop_outlined,
                              size: 14,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Humedad: ${weather.humidity}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Temperatura (entero sin decimales, más pequeño)
                  Text(
                    '${weather.temperature.round()}°C',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'CLIMA ACTUAL',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}