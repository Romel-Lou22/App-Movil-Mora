// lib/features/weather/data/models/weather_model.dart

import 'package:equatable/equatable.dart';

/// Modelo que representa los datos del clima actual
///
/// Estructura los datos que vienen de la API de OpenWeather
/// y los convierte en un objeto Dart fácil de usar
class WeatherModel extends Equatable {
  /// Temperatura actual en grados Celsius
  final double temperature;

  /// Descripción del clima en texto (ej: "cielo despejado", "nubes dispersas")
  final String description;

  /// Código del icono del clima proporcionado por OpenWeather
  /// Formato: "01d", "02n", etc.
  /// Se usa para construir la URL del icono
  final String icon;

  /// Humedad relativa en porcentaje (0-100)
  final int humidity;

  const WeatherModel({
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
  });

  /// Factory constructor que crea un WeatherModel desde JSON
  ///
  /// Recibe el Map que retorna la API y extrae los campos necesarios
  /// Ejemplo de JSON de OpenWeather:
  /// ```json
  /// {
  ///   "main": {
  ///     "temp": 18.5,
  ///     "humidity": 65
  ///   },
  ///   "weather": [
  ///     {
  ///       "description": "nubes dispersas",
  ///       "icon": "03d"
  ///     }
  ///   ]
  /// }
  /// ```
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      // Extrae la temperatura del objeto "main"
      temperature: (json['main']['temp'] as num).toDouble(),

      // Extrae la descripción del primer elemento del array "weather"
      description: json['weather'][0]['description'] as String,

      // Extrae el código del icono
      icon: json['weather'][0]['icon'] as String,

      // Extrae la humedad del objeto "main"
      humidity: json['main']['humidity'] as int,
    );
  }

  /// Convierte el modelo a JSON (útil para guardar en caché o logs)
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'description': description,
      'icon': icon,
      'humidity': humidity,
    };
  }

  /// Getter que construye la URL completa del icono del clima
  /// OpenWeather proporciona iconos en: https://openweathermap.org/img/wn/{icon}@2x.png
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// Getter que formatea la temperatura con el símbolo de grados
  /// Ejemplo: "18.5°C"
  String get temperatureFormatted => '${temperature.toStringAsFixed(1)}°C';

  /// Getter que capitaliza la primera letra de la descripción
  /// Ejemplo: "nubes dispersas" -> "Nubes dispersas"
  String get descriptionCapitalized {
    if (description.isEmpty) return description;
    return description[0].toUpperCase() + description.substring(1);
  }

  /// Equatable ayuda a comparar objetos WeatherModel
  /// Útil para saber si los datos cambiaron y actualizar la UI
  @override
  List<Object?> get props => [temperature, description, icon, humidity];

  /// Método toString para debugging
  @override
  String toString() {
    return 'WeatherModel(temp: $temperature°C, desc: $description, humidity: $humidity%)';
  }
}