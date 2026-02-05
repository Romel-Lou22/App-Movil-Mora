import 'package:dio/dio.dart';
import '../models/alert_model.dart';
import 'alert_remote_datasource.dart';

class AlertEngineRemoteDataSource {
  final Dio _dio;
  final AlertRemoteDataSource _alertsDb;

  static const String _hfUrl =
      'https://roca22-intelligent-alerts-rf.hf.space/predict';

  AlertEngineRemoteDataSource({
    required Dio dio,
    required AlertRemoteDataSource alertsDb,
  })  : _dio = dio,
        _alertsDb = alertsDb;

  Future<List<AlertModel>> generateAndPersistAlerts({
    required String parcelaId,
    required Map<String, double> features,
  }) async {
    // 1) Llamar HF
    final resp = await _dio.post(
      _hfUrl,
      options: Options(headers: {'accept': 'application/json'}),
      data: {
        'pH': features['pH'],
        'temperatura_C': features['temperatura_C'],
        'humedad_suelo_pct': features['humedad_suelo_pct'],
        'N_ppm': features['N_ppm'],
        'P_ppm': features['P_ppm'],
        'K_ppm': features['K_ppm'],
      },
    );

    final data = resp.data as Map<String, dynamic>;
    final detected = (data['alertas_detectadas'] as List<dynamic>? ?? []);

    // valores_input viene en response con humedad_suelo_% según tu ejemplo
    final valoresInputRaw = (data['valores_input'] as Map<String, dynamic>? ?? {});
    final valoresInput = valoresInputRaw.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
    );

    // 2) Mapear a AlertModel
    final models = detected.map((item) {
      final m = item as Map<String, dynamic>;
      return AlertModel.fromRandomForestResponse(
        parcelaId: parcelaId,
        tipo: m['tipo'] as String,
        recomendacion: m['recomendacion'] as String?,
        valoresInput: valoresInput,
      );
    }).toList();

    // 3) Persistir en Supabase
    if (models.isEmpty) return [];

    final inserted = await _alertsDb.insertAlerts(models);
    return inserted;
  }
}
