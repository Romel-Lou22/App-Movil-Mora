// lib/features/weather/presentation/providers/weather_provider.dart

import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../domain/usecases/get_current_weather_usecase.dart';

/// Estados posibles del provider
enum WeatherStatus {
  initial,    // Estado inicial
  loading,    // Cargando datos
  success,    // Datos cargados exitosamente
  error,      // Error al cargar
}

/// Provider que maneja el estado del clima actual
class WeatherProvider extends ChangeNotifier {

  WeatherProvider({required this.getCurrentWeatherUseCase});
  final GetCurrentWeatherUseCase getCurrentWeatherUseCase;

  // Estado actual
  WeatherStatus _status = WeatherStatus.initial;
  Weather? _weather;
  String _errorMessage = '';

  // Getters
  WeatherStatus get status => _status;
  Weather? get weather => _weather;
  String get errorMessage => _errorMessage;

  bool get isLoading => _status == WeatherStatus.loading;
  bool get hasError => _status == WeatherStatus.error;
  bool get hasData => _status == WeatherStatus.success && _weather != null;

  /// Obtiene los datos del clima actual
  Future<void> fetchCurrentWeather() async {
    _status = WeatherStatus.loading;
    notifyListeners();

    final result = await getCurrentWeatherUseCase();

    result.fold(
      // Error (Left)
          (error) {
        _status = WeatherStatus.error;
        _errorMessage = error;
        _weather = null;
        notifyListeners();
      },
      // Éxito (Right)
          (weather) {
        _status = WeatherStatus.success;
        _weather = weather;
        _errorMessage = '';
        notifyListeners();
      },
    );
  }

  /// Refresca los datos del clima
  Future<void> refresh() async {
    await fetchCurrentWeather();
  }
}