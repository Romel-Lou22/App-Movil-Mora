// lib/features/weather/domain/entities/weather.dart

import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa el clima actual
/// No depende de implementaciones externas (API, base de datos, etc.)
class Weather extends Equatable {

  const Weather({
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
  });
  final double temperature;
  final String description;
  final String icon;
  final int humidity;

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
  String get temperatureFormatted => '${temperature.toStringAsFixed(1)}°C';
  String get descriptionCapitalized {
    if (description.isEmpty) return description;
    return description[0].toUpperCase() + description.substring(1);
  }

  @override
  List<Object?> get props => [temperature, description, icon, humidity];
}