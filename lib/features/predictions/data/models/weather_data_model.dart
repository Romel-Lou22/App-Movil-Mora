import '../../domain/entities/weather_data.dart';

/// Modelo que representa datos climáticos desde la capa de datos
///
/// Extiende de WeatherData (entidad de dominio) y agrega funcionalidad
/// para convertir desde/hacia JSON (OpenWeather API y Supabase)
class WeatherDataModel extends WeatherData {
  const WeatherDataModel({
    required super.temperatura,
    required super.humedad,
    required super.descripcionClima,
    super.iconCode,
  });

  /// Factory constructor que crea un WeatherDataModel desde la respuesta de OpenWeather API
  ///
  /// Ejemplo de JSON de OpenWeather API (endpoint /weather):
  /// ```json
  /// {
  ///   "weather": [
  ///     {
  ///       "id": 803,
  ///       "main": "Clouds",
  ///       "description": "nubes dispersas",
  ///       "icon": "04d"
  ///     }
  ///   ],
  ///   "main": {
  ///     "temp": 18.5,
  ///     "humidity": 72,
  ///     "feels_like": 18.2,
  ///     "pressure": 1013
  ///   }
  /// }
  /// ```
  ///
  /// Nota: Se espera que el API se llame con parámetros:
  /// - units=metric (para temperatura en Celsius)
  /// - lang=es (para descripción en español)
  factory WeatherDataModel.fromOpenWeatherResponse(
      Map<String, dynamic> json,
      ) {
    // Extraer el primer elemento del array weather
    final weatherArray = json['weather'] as List;
    if (weatherArray.isEmpty) {
      throw Exception('No se encontraron datos de clima en la respuesta');
    }

    final weather = weatherArray[0] as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;

    return WeatherDataModel(
      temperatura: (main['temp'] as num).toDouble(),
      humedad: (main['humidity'] as num).toDouble(),
      descripcionClima: weather['description'] as String,
      iconCode: weather['icon'] as String,
    );
  }

  /// Factory constructor que crea un WeatherDataModel desde JSON de Supabase
  ///
  /// Ejemplo de JSON de Supabase (tabla datos_historicos):
  /// ```json
  /// {
  ///   "temperatura": 18.5,
  ///   "humedad": 72,
  ///   "descripcion_clima": "nubes dispersas"
  /// }
  /// ```
  ///
  /// Nota: El iconCode NO viene de Supabase porque no se guarda en BD
  factory WeatherDataModel.fromSupabaseJson(Map<String, dynamic> json) {
    return WeatherDataModel(
      temperatura: (json['temperatura'] as num).toDouble(),
      humedad: (json['humedad'] as num).toDouble(),
      descripcionClima: json['descripcion_clima'] as String,
      iconCode: null, // No se guarda en BD
    );
  }

  /// Convierte el modelo a un Map para guardar en Supabase
  ///
  /// Solo incluye los campos que existen en la tabla datos_historicos:
  /// - temperatura
  /// - humedad
  /// - descripcion_clima
  ///
  /// NO incluye iconCode porque no se persiste en BD
  Map<String, dynamic> toSupabaseMap() {
    return {
      'temperatura': temperatura,
      'humedad': humedad,
      'descripcion_clima': descripcionClima,
    };
  }

  /// Convierte la entidad WeatherData a WeatherDataModel
  factory WeatherDataModel.fromEntity(WeatherData entity) {
    return WeatherDataModel(
      temperatura: entity.temperatura,
      humedad: entity.humedad,
      descripcionClima: entity.descripcionClima,
      iconCode: entity.iconCode,
    );
  }

  /// Crea una copia del modelo con campos modificados
  @override
  WeatherDataModel copyWith({
    double? temperatura,
    double? humedad,
    String? descripcionClima,
    String? iconCode,
  }) {
    return WeatherDataModel(
      temperatura: temperatura ?? this.temperatura,
      humedad: humedad ?? this.humedad,
      descripcionClima: descripcionClima ?? this.descripcionClima,
      iconCode: iconCode ?? this.iconCode,
    );
  }
}