import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/parcela.dart';
import '../../domain/repositories/parcela_repository.dart';
import '../datasources/parcela_remote_datasource.dart';

/// Implementación del repositorio de parcelas
/// Conecta la capa Domain con la capa Data
/// Maneja errores y convierte excepciones en Failures
class ParcelaRepositoryImpl implements ParcelaRepository {
  final ParcelaRemoteDataSource remoteDataSource;

  ParcelaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Parcela>>> getParcelas() async {
    try {
      // Llamar al datasource para obtener parcelas
      final parcelaModels = await remoteDataSource.getParcelas();

      // Convertir ParcelaModel (Data) a Parcela (Domain)
      final parcelas = parcelaModels
          .map((model) => model.toEntity())
          .toList();

      return Right(parcelas);
    } catch (e) {
      // Mapear la excepción a un Failure específico
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Parcela>> getParcelaById(String parcelaId) async {
    try {
      // Llamar al datasource para obtener la parcela
      final parcelaModel = await remoteDataSource.getParcelaById(parcelaId);

      // Convertir a entidad de dominio
      return Right(parcelaModel.toEntity());
    } catch (e) {
      // Mapear la excepción a un Failure específico
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Parcela>> createParcela({
    required String nombreParcela,
    double? latitud,
    double? longitud,
    bool usaUbicacionDefault = false,
    double? areaHectareas,
  }) async {
    try {
      // Llamar al datasource para crear la parcela
      final parcelaModel = await remoteDataSource.createParcela(
        nombreParcela: nombreParcela,
        latitud: latitud,
        longitud: longitud,
        usaUbicacionDefault: usaUbicacionDefault,
        areaHectareas: areaHectareas,
      );

      // Convertir a entidad de dominio
      return Right(parcelaModel.toEntity());
    } catch (e) {
      // Mapear la excepción a un Failure específico
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Parcela>> updateParcela({
    required String parcelaId,
    String? nombreParcela,
    double? latitud,
    double? longitud,
    bool? usaUbicacionDefault,
    double? areaHectareas,
  }) async {
    try {
      // Llamar al datasource para actualizar la parcela
      final parcelaModel = await remoteDataSource.updateParcela(
        parcelaId: parcelaId,
        nombreParcela: nombreParcela,
        latitud: latitud,
        longitud: longitud,
        usaUbicacionDefault: usaUbicacionDefault,
        areaHectareas: areaHectareas,
      );

      // Convertir a entidad de dominio
      return Right(parcelaModel.toEntity());
    } catch (e) {
      // Mapear la excepción a un Failure específico
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteParcela(String parcelaId) async {
    try {
      // Llamar al datasource para desactivar la parcela
      await remoteDataSource.deleteParcela(parcelaId);

      return const Right(null);
    } catch (e) {
      // Mapear la excepción a un Failure específico
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Parcela>> reactivarParcela(String parcelaId) async {
    try {
      // Llamar al datasource para reactivar la parcela
      final parcelaModel = await remoteDataSource.reactivarParcela(parcelaId);

      // Convertir a entidad de dominio
      return Right(parcelaModel.toEntity());
    } catch (e) {
      // Mapear la excepción a un Failure específico
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, int>> getConteoParcelasActivas() async {
    try {
      // Llamar al datasource para contar parcelas
      final conteo = await remoteDataSource.getConteoParcelasActivas();

      return Right(conteo);
    } catch (e) {
      // Mapear la excepción a un Failure específico
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Mapea excepciones a Failures específicos con mensajes en español
  Failure _mapExceptionToFailure(dynamic exception) {
    final errorMessage = exception.toString().toLowerCase();

    // Error de autenticación
    if (errorMessage.contains('usuario no autenticado') ||
        errorMessage.contains('not authenticated')) {
      return const UnauthenticatedFailure();
    }

    // Error de parcela no encontrada
    if (errorMessage.contains('parcela no encontrada') ||
        errorMessage.contains('no rows found') ||
        errorMessage.contains('not found')) {
      return const ValidationFailure('Parcela no encontrada');

    }

    // Error de permisos
    if (errorMessage.contains('sin permisos') ||
        errorMessage.contains('permission denied') ||
        errorMessage.contains('unauthorized')) {
      return const PermissionDeniedFailure();
    }

    // Error de validación
    if (errorMessage.contains('no hay campos para actualizar') ||
        errorMessage.contains('validation') ||
        errorMessage.contains('invalid')) {
      return ValidationFailure(exception.toString());
    }

    // Errores de red
    if (errorMessage.contains('network') ||
        errorMessage.contains('socket') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('failed host lookup')) {
      return const NetworkFailure();
    }

    if (errorMessage.contains('timeout')) {
      return const TimeoutFailure();
    }

    // Error de límite de parcelas (opcional)
    if (errorMessage.contains('límite de parcelas') ||
        errorMessage.contains('limit exceeded')) {
      return const ValidationFailure(
        'Has alcanzado el límite de parcelas permitidas',
      );
    }

    // Error genérico
    return UnknownFailure(exception.toString());
  }
}