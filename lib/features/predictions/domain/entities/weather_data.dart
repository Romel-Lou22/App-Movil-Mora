import 'package:equatable/equatable.dart';

/// Entidad que representa los datos climáticos en tiempo real
///
/// Datos obtenidos desde OpenWeather API
class WeatherData extends Equatable {
  /// Temperatura actual en grados Celsius
  final double temperatura;

  /// Humedad relativa en porcentaje (0-100)
  final double humedad;

  /// Descripción del clima en español (ej: "nubes dispersas")
  final String descripcionClima;

  /// Código del icono de OpenWeather (ej: "04d")
  /// Este campo NO se guarda en BD, solo se usa en UI
  final String? iconCode;

  const WeatherData({
    required this.temperatura,
    required this.humedad,
    required this.descripcionClima,
    this.iconCode,
  });

  /// Obtiene la URL completa del icono de OpenWeather
  String? get iconUrl => iconCode != null
      ? 'https://openweathermap.org/img/wn/$iconCode@2x.png'
      : null;

  /// Verifica si la temperatura es alta (>25°C)
  bool get isHot => temperatura > 25;

  /// Verifica si la temperatura es baja (<10°C)
  bool get isCold => temperatura < 10;

  /// Verifica si la temperatura está en rango óptimo para mora (10-25°C)
  bool get isOptimalTemperature => temperatura >= 10 && temperatura <= 25;

  /// Verifica si la humedad es alta (>80%)
  bool get isHighHumidity => humedad > 80;

  /// Verifica si la humedad es baja (<60%)
  bool get isLowHumidity => humedad < 60;

  /// Verifica si la humedad está en rango óptimo para mora (60-80%)
  bool get isOptimalHumidity => humedad >= 60 && humedad <= 80;

  /// Obtiene el emoji según la condición climática
  String get weatherEmoji {
    if (descripcionClima.contains('despejado') ||
        descripcionClima.contains('claro')) {
      return '☀️';
    }
    if (descripcionClima.contains('nube')) {
      return '☁️';
    }
    if (descripcionClima.contains('lluvia')) {
      return '🌧️';
    }
    if (descripcionClima.contains('tormenta')) {
      return '⛈️';
    }
    if (descripcionClima.contains('niebla')) {
      return '🌫️';
    }
    return '🌤️';
  }

  /// Crea una copia con campos modificados
  WeatherData copyWith({
    double? temperatura,
    double? humedad,
    String? descripcionClima,
    String? iconCode,
  }) {
    return WeatherData(
      temperatura: temperatura ?? this.temperatura,
      humedad: humedad ?? this.humedad,
      descripcionClima: descripcionClima ?? this.descripcionClima,
      iconCode: iconCode ?? this.iconCode,
    );
  }

  @override
  List<Object?> get props => [
    temperatura,
    humedad,
    descripcionClima,
    iconCode,
  ];

  @override
  String toString() {
    return 'WeatherData(temp: ${temperatura.toStringAsFixed(1)}°C, hum: ${humedad.toStringAsFixed(0)}%, desc: $descripcionClima)';
  }
}