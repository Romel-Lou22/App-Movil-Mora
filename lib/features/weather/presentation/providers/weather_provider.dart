// lib/features/weather/presentation/providers/weather_provider.dart

import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../domain/usecases/get_current_weather_usecase.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherProvider extends ChangeNotifier {
  WeatherProvider({required this.getCurrentWeatherUseCase});
  final GetCurrentWeatherUseCase getCurrentWeatherUseCase;

  WeatherStatus _status = WeatherStatus.initial;
  Weather? _weather;
  String _errorMessage = '';

  WeatherStatus get status => _status;
  Weather? get weather => _weather;
  String get errorMessage => _errorMessage;

  bool get isLoading => _status == WeatherStatus.loading;
  bool get hasError => _status == WeatherStatus.error;
  bool get hasData => _status == WeatherStatus.success && _weather != null;

  /// Obtiene los datos del clima actual para coordenadas específicas
  Future<void> fetchCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    _status = WeatherStatus.loading;
    notifyListeners();

    final result = await getCurrentWeatherUseCase(lat: lat, lon: lon);

    result.fold(
          (error) {
        _status = WeatherStatus.error;
        _errorMessage = error;
        _weather = null;
        notifyListeners();
      },
          (weather) {
        _status = WeatherStatus.success;
        _weather = weather;
        _errorMessage = '';
        notifyListeners();
      },
    );
  }

  /// Refresca (requiere lat/lon)
  Future<void> refresh({
    required double lat,
    required double lon,
  }) async {
    await fetchCurrentWeather(lat: lat, lon: lon);
  }
}
