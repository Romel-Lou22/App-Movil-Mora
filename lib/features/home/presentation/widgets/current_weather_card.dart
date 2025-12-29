// lib/features/weather/presentation/widgets/current_weather_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../weather/presentation/providers/weather_provider.dart';

class CurrentWeatherCard extends StatefulWidget {
  const CurrentWeatherCard({super.key});

  @override
  State<CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al iniciar el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchCurrentWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        // Estado: Cargando
        if (weatherProvider.isLoading) {
          return _buildContainer(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Estado: Error
        if (weatherProvider.hasError) {
          return _buildContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT WEATHER',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${weatherProvider.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => weatherProvider.refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Estado: Datos cargados
        final weather = weatherProvider.weather;
        if (weather == null) {
          return _buildContainer(
            child: const Text('No hay datos disponibles'),
          );
        }

        return _buildContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'CURRENT WEATHER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),

              // Contenido principal
              Row(
                children: [
                  // Icono del clima desde la API
                  Image.network(
                    weather.iconUrl,
                    width: 64,
                    height: 64,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.wb_cloudy_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.6),
                      );
                    },
                  ),
                  const SizedBox(width: 16),

                  // Descripción del clima
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.descriptionCapitalized,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Humedad: ${weather.humidity}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Temperatura
                  Text(
                    weather.temperatureFormatted,
                    style: const TextStyle(
                      fontSize: 48,
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

  /// Widget reutilizable para el contenedor del card
  Widget _buildContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}