import 'package:flutter/foundation.dart';

import '../../domain/entities/parcela.dart';
import '../../domain/usecases/create_parcela_usecase.dart';
import '../../domain/usecases/delete_parcela_usecase.dart';
import '../../domain/usecases/get_parcela_by_id_usecase.dart';
import '../../domain/usecases/get_parcelas_usecase.dart';
import '../../domain/usecases/update_parcela_usecase.dart';

/// Estados posibles de las operaciones con parcelas
enum ParcelaStatus {
  initial,      // Estado inicial
  loading,      // Cargando datos
  loaded,       // Datos cargados exitosamente
  creating,     // Creando parcela
  updating,     // Actualizando parcela
  deleting,     // Eliminando parcela
  error,        // Error en alguna operación
}

/// Provider para manejar el estado de las parcelas
/// Usa ChangeNotifier de Provider para gestión de estado
class ParcelaProvider extends ChangeNotifier {
  // === Use Cases ===
  final GetParcelasUseCase getParcelasUseCase;
  final GetParcelaByIdUseCase getParcelaByIdUseCase;
  final CreateParcelaUseCase createParcelaUseCase;
  final UpdateParcelaUseCase updateParcelaUseCase;
  final DeleteParcelaUseCase deleteParcelaUseCase;

  ParcelaProvider({
    required this.getParcelasUseCase,
    required this.getParcelaByIdUseCase,
    required this.createParcelaUseCase,
    required this.updateParcelaUseCase,
    required this.deleteParcelaUseCase,
  });

  // === Estado ===
  ParcelaStatus _status = ParcelaStatus.initial;
  List<Parcela> _parcelas = [];
  Parcela? _parcelaSeleccionada;
  String? _errorMessage;

  // === Getters ===
  ParcelaStatus get status => _status;
  List<Parcela> get parcelas => _parcelas;
  Parcela? get parcelaSeleccionada => _parcelaSeleccionada;
  String? get errorMessage => _errorMessage;

  // Getters de conveniencia
  bool get isLoading => _status == ParcelaStatus.loading;
  bool get isCreating => _status == ParcelaStatus.creating;
  bool get isUpdating => _status == ParcelaStatus.updating;
  bool get isDeleting => _status == ParcelaStatus.deleting;
  bool get hasError => _status == ParcelaStatus.error;
  bool get hasParcelas => _parcelas.isNotEmpty;
  int get cantidadParcelas => _parcelas.length;

  /// Verifica si hay una parcela seleccionada
  bool get tieneParcelaSeleccionada => _parcelaSeleccionada != null;

  // === Métodos Principales ===

  /// Obtiene todas las parcelas activas del usuario
  Future<void> fetchParcelas() async {
    _setStatus(ParcelaStatus.loading);
    _errorMessage = null;

    // Ejecutar el caso de uso
    final result = await getParcelasUseCase();

    // Manejar el resultado
    result.fold(
      // Error (Left)
          (failure) {
        _setStatus(ParcelaStatus.error);
        _errorMessage = failure.message;
        _parcelas = [];
      },
      // Éxito (Right)
          (parcelas) {
        _setStatus(ParcelaStatus.loaded);
        _parcelas = parcelas;
        _errorMessage = null;

        // Si hay parcelas y no hay una seleccionada, seleccionar la primera
        if (_parcelas.isNotEmpty && _parcelaSeleccionada == null) {
          _parcelaSeleccionada = _parcelas.first;
        }

        // Si la parcela seleccionada ya no existe en la lista, actualizar
        if (_parcelaSeleccionada != null) {
          final existe = _parcelas.any((p) => p.id == _parcelaSeleccionada!.id);
          if (!existe) {
            _parcelaSeleccionada = _parcelas.isNotEmpty ? _parcelas.first : null;
          }
        }
      },
    );
  }

  /// Obtiene una parcela específica por ID
  Future<Parcela?> getParcelaById(String parcelaId) async {
    final result = await getParcelaByIdUseCase(parcelaId);

    return result.fold(
          (failure) => null,
          (parcela) => parcela,
    );
  }

  /// Crea una nueva parcela
  Future<bool> createParcela({
    required String nombreParcela,
    double? latitud,
    double? longitud,
    bool usaUbicacionDefault = false,
    double? areaHectareas,
  }) async {
    _setStatus(ParcelaStatus.creating);
    _errorMessage = null;

    // Ejecutar el caso de uso
    final result = await createParcelaUseCase(
      nombreParcela: nombreParcela,
      latitud: latitud,
      longitud: longitud,
      usaUbicacionDefault: usaUbicacionDefault,
      areaHectareas: areaHectareas,
    );

    // Manejar el resultado
    return result.fold(
      // Error (Left)
          (failure) {
        _setStatus(ParcelaStatus.error);
        _errorMessage = failure.message;
        return false;
      },
      // Éxito (Right)
          (nuevaParcela) {
        _setStatus(ParcelaStatus.loaded);
        _errorMessage = null;

        // Agregar la nueva parcela a la lista
        _parcelas.insert(0, nuevaParcela); // Al inicio (más reciente)

        // Si es la primera parcela, seleccionarla automáticamente
        if (_parcelas.length == 1) {
          _parcelaSeleccionada = nuevaParcela;
        }

        return true;
      },
    );
  }

  /// Actualiza una parcela existente
  Future<bool> updateParcela({
    required String parcelaId,
    String? nombreParcela,
    double? latitud,
    double? longitud,
    bool? usaUbicacionDefault,
    double? areaHectareas,
  }) async {
    _setStatus(ParcelaStatus.updating);
    _errorMessage = null;

    // Ejecutar el caso de uso
    final result = await updateParcelaUseCase(
      parcelaId: parcelaId,
      nombreParcela: nombreParcela,
      latitud: latitud,
      longitud: longitud,
      usaUbicacionDefault: usaUbicacionDefault,
      areaHectareas: areaHectareas,
    );

    // Manejar el resultado
    return result.fold(
      // Error (Left)
          (failure) {
        _setStatus(ParcelaStatus.error);
        _errorMessage = failure.message;
        return false;
      },
      // Éxito (Right)
          (parcelaActualizada) {
        _setStatus(ParcelaStatus.loaded);
        _errorMessage = null;

        // Actualizar la parcela en la lista
        final index = _parcelas.indexWhere((p) => p.id == parcelaId);
        if (index != -1) {
          _parcelas[index] = parcelaActualizada;
        }

        // Si es la parcela seleccionada, actualizarla también
        if (_parcelaSeleccionada?.id == parcelaId) {
          _parcelaSeleccionada = parcelaActualizada;
        }

        return true;
      },
    );
  }

  /// Desactiva una parcela (soft delete)
  Future<bool> deleteParcela(String parcelaId) async {
    _setStatus(ParcelaStatus.deleting);
    _errorMessage = null;

    // Ejecutar el caso de uso
    final result = await deleteParcelaUseCase(parcelaId);

    // Manejar el resultado
    return result.fold(
      // Error (Left)
          (failure) {
        _setStatus(ParcelaStatus.error);
        _errorMessage = failure.message;
        return false;
      },
      // Éxito (Right)
          (_) {
        _setStatus(ParcelaStatus.loaded);
        _errorMessage = null;

        // Remover la parcela de la lista
        _parcelas.removeWhere((p) => p.id == parcelaId);

        // Si era la parcela seleccionada, seleccionar otra
        if (_parcelaSeleccionada?.id == parcelaId) {
          _parcelaSeleccionada = _parcelas.isNotEmpty ? _parcelas.first : null;
        }

        return true;
      },
    );
  }

  // === Gestión de Parcela Seleccionada ===

  /// Establece la parcela seleccionada (la que se muestra en el HomeScreen)
  void setParcelaSeleccionada(Parcela parcela) {
    if (_parcelaSeleccionada?.id != parcela.id) {
      _parcelaSeleccionada = parcela;
      notifyListeners();

      debugPrint('🌾 Parcela seleccionada: ${parcela.nombreParcela}');
    }
  }

  /// Establece la parcela seleccionada por ID
  void setParcelaSeleccionadaById(String parcelaId) {
    final parcela = _parcelas.firstWhere(
          (p) => p.id == parcelaId,
      orElse: () => Parcela.empty,
    );

    if (parcela.isNotEmpty) {
      setParcelaSeleccionada(parcela);
    }
  }

  /// Limpia la parcela seleccionada
  void clearParcelaSeleccionada() {
    _parcelaSeleccionada = null;
    notifyListeners();
  }

  // === Métodos de Utilidad ===

  /// Limpia el mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Cambia el estado y notifica a los listeners
  void _setStatus(ParcelaStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  /// Resetea el provider al estado inicial
  void reset() {
    _status = ParcelaStatus.initial;
    _parcelas = [];
    _parcelaSeleccionada = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresca las parcelas (útil para pull-to-refresh)
  Future<void> refresh() async {
    await fetchParcelas();
  }
}