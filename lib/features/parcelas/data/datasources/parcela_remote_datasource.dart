import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../models/parcela_model.dart';

/// Interfaz abstracta del DataSource de Parcelas
/// Define los métodos que debe implementar el datasource remoto
abstract class ParcelaRemoteDataSource {
  /// Obtiene todas las parcelas activas del usuario autenticado
  Future<List<ParcelaModel>> getParcelas();

  /// Obtiene una parcela específica por su ID
  Future<ParcelaModel> getParcelaById(String parcelaId);

  /// Crea una nueva parcela
  Future<ParcelaModel> createParcela({
    required String nombreParcela,
    double? latitud,
    double? longitud,
    bool usaUbicacionDefault = false,
    double? areaHectareas,
  });

  /// Actualiza una parcela existente
  Future<ParcelaModel> updateParcela({
    required String parcelaId,
    String? nombreParcela,
    double? latitud,
    double? longitud,
    bool? usaUbicacionDefault,
    double? areaHectareas,
  });

  /// Desactiva una parcela (soft delete)
  Future<void> deleteParcela(String parcelaId);

  /// Reactiva una parcela
  Future<ParcelaModel> reactivarParcela(String parcelaId);

  /// Obtiene el conteo de parcelas activas
  Future<int> getConteoParcelasActivas();
}

/// Implementación del DataSource remoto usando Supabase
class ParcelaRemoteDataSourceImpl implements ParcelaRemoteDataSource {
  final SupabaseClient _supabase;

  ParcelaRemoteDataSourceImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseConfig.supabase;

  @override
  Future<List<ParcelaModel>> getParcelas() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabase
          .from('parcelas')
          .select()
          .eq('usuario_id', userId)
          .eq('activa', true)
          .order('fecha_creacion', ascending: false);

      return (response as List)
          .map((json) => ParcelaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener parcelas: $e');
    }
  }


  @override
  Future<ParcelaModel> getParcelaById(String parcelaId) async {
    try {
      // Obtener el ID del usuario autenticado
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Consultar la parcela específica
      final response = await _supabase
          .from('parcelas')
          .select()
          .eq('id', parcelaId)
          .eq('usuario_id', userId)
          .single();

      // Convertir a ParcelaModel
      return ParcelaModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        throw Exception('Parcela no encontrada');
      }
      throw Exception('Error al obtener parcela: $e');
    }
  }

  @override
  Future<ParcelaModel> createParcela({
    required String nombreParcela,
    double? latitud,
    double? longitud,
    bool usaUbicacionDefault = false,
    double? areaHectareas,
  }) async {
    try {
      // Obtener el ID del usuario autenticado
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Preparar datos para insertar
      final data = {
        'usuario_id': userId,
        'nombre_parcela': nombreParcela,
        'latitud': usaUbicacionDefault ? null : latitud,
        'longitud': usaUbicacionDefault ? null : longitud,
        'usa_ubicacion_default': usaUbicacionDefault,
        'area_hectareas': areaHectareas,
        'activa': true,
      };

      // Insertar en Supabase y obtener el registro creado
      final response = await _supabase
          .from('parcelas')
          .insert(data)
          .select()
          .single();

      // Convertir a ParcelaModel
      return ParcelaModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear parcela: $e');
    }
  }

  @override
  Future<ParcelaModel> updateParcela({
    required String parcelaId,
    String? nombreParcela,
    double? latitud,
    double? longitud,
    bool? usaUbicacionDefault,
    double? areaHectareas,
  }) async {
    try {
      // Obtener el ID del usuario autenticado
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Preparar datos para actualizar (solo campos proporcionados)
      final updates = <String, dynamic>{};

      if (nombreParcela != null) {
        updates['nombre_parcela'] = nombreParcela;
      }

      if (usaUbicacionDefault != null) {
        updates['usa_ubicacion_default'] = usaUbicacionDefault;

        if (usaUbicacionDefault) {
          // Si se activa ubicación por defecto, limpiar coordenadas
          updates['latitud'] = null;
          updates['longitud'] = null;
        }
      }

      if (latitud != null && usaUbicacionDefault != true) {
        updates['latitud'] = latitud;
      }

      if (longitud != null && usaUbicacionDefault != true) {
        updates['longitud'] = longitud;
      }

      if (areaHectareas != null) {
        updates['area_hectareas'] = areaHectareas;
      }

      // Si no hay nada que actualizar, lanzar excepción
      if (updates.isEmpty) {
        throw Exception('No hay campos para actualizar');
      }

      // Actualizar en Supabase
      final response = await _supabase
          .from('parcelas')
          .update(updates)
          .eq('id', parcelaId)
          .eq('usuario_id', userId)
          .select()
          .single();

      // Convertir a ParcelaModel
      return ParcelaModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        throw Exception('Parcela no encontrada o sin permisos');
      }
      throw Exception('Error al actualizar parcela: $e');
    }
  }

  @override
  Future<void> deleteParcela(String parcelaId) async {
    try {
      // Obtener el ID del usuario autenticado
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Desactivar la parcela (soft delete)
      await _supabase
          .from('parcelas')
          .update({'activa': false})
          .eq('id', parcelaId)
          .eq('usuario_id', userId);
    } catch (e) {
      throw Exception('Error al desactivar parcela: $e');
    }
  }

  @override
  Future<ParcelaModel> reactivarParcela(String parcelaId) async {
    try {
      // Obtener el ID del usuario autenticado
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Reactivar la parcela
      final response = await _supabase
          .from('parcelas')
          .update({'activa': true})
          .eq('id', parcelaId)
          .eq('usuario_id', userId)
          .select()
          .single();

      // Convertir a ParcelaModel
      return ParcelaModel.fromJson(response);
    } catch (e) {
      if (e.toString().contains('No rows found')) {
        throw Exception('Parcela no encontrada o sin permisos');
      }
      throw Exception('Error al reactivar parcela: $e');
    }
  }

  @override
  Future<int> getConteoParcelasActivas() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final count = await _supabase
          .from('parcelas')
          .count()
          .eq('usuario_id', userId)
          .eq('activa', true);

      return count;
    } catch (e) {
      throw Exception('Error al contar parcelas: $e');
    }
  }

}