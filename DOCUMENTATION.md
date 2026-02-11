# Documentación: EcoMora — Resumen del flujo de la aplicación

Fecha: 2026-02-10

---

Este documento resume el propósito, flujo, arquitectura, archivos clave, preguntas de defensa, guion de presentación y pasos para ejecutar la app EcoMora (Flutter) — listo para usar en una defensa ante un tutor.

## 1) Resumen de alto nivel
- EcoMora es una app Flutter para monitoreo agrícola de cultivos de mora (Tisaleo, Ecuador). Ofrece autenticación, gestión de parcelas, predicciones, clima, alertas y estadísticas.
- Arquitectura: separación en capas inspirada en Clean Architecture: presentation (providers/screens), domain (usecases/entities), data (datasources/repositories). Backend principal: Supabase.

## 2) Flujo de inicio / secuencia de inicialización
- `lib/main.dart` — entry point:
  - Inicializa widgets, fija orientación (portrait), intenta inicializar Supabase con `SupabaseConfig.initialize()` que carga `.env`.
  - Ejecuta `runApp(const EcoMoraApp())`.
- `lib/app.dart` — `EcoMoraApp`:
  - Define `MultiProvider` con `AuthProvider`, `WeatherProvider`, `AlertProvider`, `PredictionProvider`, `ParcelaProvider`, `StatisticsProvider`.
  - Configura `MaterialApp` con `home: const SplashScreen()` y las rutas en `AppRoutes`.
- `lib/features/splash/presentation/screens/splash_screen.dart` — Splash:
  - Animaciones y secuencia de inicialización; al finalizar navega a `AppRoutes.login` (LoginScreen).
- `LoginScreen`/`RegisterScreen` usan `AuthProvider` que ejecuta `LoginUseCase`/`RegisterUseCase` → `AuthRepositoryImpl` → `AuthRemoteDataSourceImpl` (Supabase).

## 2.1) Orden de inicialización y quién entra en funcionamiento primero
- Orden en arranque (secuencia):
  1. `main()` en `lib/main.dart` — WidgetsBinding.ensureInitialized() y llamadas de configuración (orientación, Supabase).
  2. `SupabaseConfig.initialize()` (intenta cargar `.env` y configura Supabase). Si falla, la app aún puede iniciarse pero algunas funcionalidades remotas no estarán disponibles.
  3. `runApp(const EcoMoraApp())` — crea el árbol de widgets y ejecuta `EcoMoraApp`.
  4. `EcoMoraApp.build()` — aquí se crea el `MultiProvider`. Todos los `ChangeNotifierProvider` definidos en `app.dart` se instancian cuando se construye el `MultiProvider` (por lo tanto están disponibles para cualquier pantalla que se muestre después).
  5. `MaterialApp` arranca y carga `home: const SplashScreen()`.
  6. `SplashScreen.initState()` realiza tareas de inicio y finalmente navega a `AppRoutes.login`.
  7. La pantalla `LoginScreen` usa `AuthProvider` (ya creado) para autenticar; los providers llaman a sus `usecases` y repositorios según sea necesario.

> Importante: los providers se crean en el arranque dentro de `app.dart`, por eso están disponibles globalmente; los datasources/repositories/usecases se crean dentro del `create:` de cada `ChangeNotifierProvider`.

## 3) Diagrama textual de navegación
- main → Supabase.initialize() → runApp(EcoMoraApp)
- EcoMoraApp → SplashScreen (/) → pushReplacementNamed(AppRoutes.login)
- LoginScreen → (login OK) → DataLoadingScreen? o MainShellScreen
- MainShellScreen (tabs): Home, Predictions, Alerts, Parcelas, Statistics

Flujo típico (login → predicción):
1. Usuario abre app → Splash → Login
2. Inicia sesión → `AuthProvider.login()` → usecase → repo → Supabase
3. Al autenticarse: MainShellScreen → seleccionar "Predictions" → `PredictionProvider` ejecuta `GetSoilPredictionUseCase` → se consultan OpenWeather y HuggingFace → UI muestra resultado

## 4) Cómo se conectan los archivos (mapeo de capas y flujo de datos)
A continuación detallo cómo se conectan típicamente los archivos dentro de una feature. Cada feature en el proyecto sigue la estructura: `presentation/`, `domain/`, `data/`. Esta sección explica el flujo y quién llama a quién.

- Estructura típica por feature (ejemplo: `features/parcelas`):
  - `presentation/` — pantallas (screens), widgets y `providers` (ChangeNotifier).
  - `domain/` — `entities/`, `usecases/` e interfaces de repositorios (contratos).
  - `data/` — `datasources/` (remote/local), `models/`, `repositories/` (implementaciones concretas que cumplen las interfaces del domain).

- Flujo general (llamada hacia abajo y retorno hacia arriba):
  1. UI (Screen/Widget) invoca métodos del `Provider` (por ejemplo `context.read<ParcelaProvider>().fetchParcelas()` o mediante `Consumer`).
  2. `Provider` (ChangeNotifier) implementa la lógica de presentación mínima: cambia estados (`loading`, `success`, `error`), y llama al `UseCase` correspondiente (por ejemplo `GetParcelasUseCase`).
  3. `UseCase` reside en `domain/` y encapsula la lógica de negocio; recibe el `Repository` (contrato) y ejecuta la lógica necesaria retornando `Either<Failure, T>`.
  4. `Repository` (implementación en `data/repositories/`), implementa la interfaz definida en `domain/repositories/`. El `Repository` decide de dónde obtener los datos (datasource remoto o local), transformar `Model` → `Entity` y manejar errores / mapeo a `Failure`.
  5. `DataSource` (`data/datasources/`) hace la llamada HTTP o DB (Supabase) y devuelve `Model`s.
  6. `Model` se convierte a `Entity` y el resultado sube: DataSource → Repository → UseCase → Provider → UI.

- Ejemplo concreto (Parcelas):
  - UI: `ParcelasListScreen` (presentation/screen) llama a `ParcelaProvider.fetchParcelas()` en `initState`.
  - Provider: `ParcelaProvider` setea `_status = loading`, llama a `getParcelasUseCase()`.
  - UseCase: `GetParcelasUseCase` llama a `ParcelaRepository.getParcelas()`.
  - Repository impl: `ParcelaRepositoryImpl` llama a `ParcelaRemoteDataSourceImpl.getParcelas()`.
  - DataSource: `ParcelaRemoteDataSourceImpl` usa `SupabaseConfig.supabase` para consultar la tabla/endpoint y devuelve `ParcelaModel`.
  - Transformación: `ParcelaModel.toEntity()` → lista de `Parcela` (domain/entity).
  - Resultado: arriba en `ParcelaProvider`, `_parcelaList = result` y notifica UI.

- Ejemplo concreto (Predictions):
  - UI: `PredictionsScreen` solicita `context.read<PredictionProvider>().getSoilPrediction(lat, lon)`.
  - Provider: `PredictionProvider` setea `loading` y llama a `GetSoilPredictionUseCase`.
  - UseCase: `GetSoilPredictionUseCase` usa `PredictionRepository` para obtener datos agregados.
  - Repository impl: `PredictionRepositoryImpl` combina datos de `OpenWeatherDataSource` y `HuggingFaceDataSource` (ambos en `data/datasources/`) y devuelve `PredictionModel` o entidades.
  - DataSources: `OpenWeatherDataSource` (HTTP via Dio) y `HuggingFaceDataSource` (HTTP) retornan modelos que se combinan y normalizan.
  - Resultado: `PredictionProvider` recibe datos formateados y actualiza la UI.

## 5) Archivos y clases clave (ruta + 1 línea)
- `lib/main.dart` — Inicia la app, fija orientación e inicializa Supabase.
- `lib/app.dart` — `EcoMoraApp`: registra providers, configura `MaterialApp` y rutas.
- `lib/core/config/supabase_config.dart` — Inicializa y expone el cliente de Supabase.
- `lib/core/config/routes/app_routes.dart` — Constantes de rutas.
- `lib/features/splash/presentation/screens/splash_screen.dart` — Splash y lógica de navegación inicial.
- `lib/features/auth/presentation/providers/auth_provider.dart` — Estado y métodos de autenticación.
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` — Implementación Supabase para auth.
- `lib/features/auth/data/repositories/auth_repository_impl.dart` — Repositorio de auth (Either/Failure).
- `lib/features/home/presentation/screens/main_shell_screen.dart` — Contenedor con tabs principales.
- `lib/features/predictions/presentation/providers/prediction_provider.dart` — Orquesta la obtención de predicciones.
- `lib/features/parcelas/presentation/providers/parcela_provider.dart` — CRUD de parcelas.
- `lib/features/alerts/presentation/providers/alert_provider.dart` — Gestión y evaluación de alertas.
- `lib/features/weather/presentation/providers/weather_provider.dart` — Obtención de clima.
- `pubspec.yaml` — Dependencias: provider, flutter_riverpod (no usado), supabase_flutter, dio, fl_chart, flutter_dotenv, dartz, etc.

## 6) Preguntas probables del tutor y respuestas cortas
1. ¿Qué patrón arquitectónico usaste?
   - Capas tipo Clean Architecture: presentation/domain/data con usecases y repositorios.
2. ¿Cómo se maneja la autenticación?
   - Con Supabase (`supabase_flutter`); `AuthRemoteDataSourceImpl` usa Supabase Auth; repositorio devuelve `Either<Failure,User>`.
3. ¿Por qué `provider` y no `Riverpod`?
   - Se usó `provider` por simplicidad y continuidad del proyecto; `flutter_riverpod` está en deps pero no usado aún.
4. ¿Cómo pruebas la lógica de negocio?
   - `flutter_test` y `mockito` están en dev-deps; se recomienda escribir tests para usecases y repositorios usando mocks.
5. ¿Dónde corren las predicciones?
   - En un servicio externo (HuggingFace + OpenWeather), no en el dispositivo.
6. ¿Cómo inyecto dependencias?
   - Inyección manual en `EcoMoraApp`. Recomendación: migrar a `get_it` o a Riverpod para mejorar testabilidad.
7. ¿Cómo se manejan errores de red?
   - Repositorios retornan `Either` con `Failure`; providers ajustan estado `loading/error/success`.

## 7) Guion de defensa (~3 minutos)
- Inicio (20s): "EcoMora es una app móvil para monitoreo de cultivos de mora: auth, parcelas, predicciones, alertas y estadísticas."
- Arquitectura (40s): "Separa presentation/domain/data; los usecases dictan la lógica, los repositorios abstraen datos y los providers notifican la UI."
- Flujo (40s): "main → Supabase → Splash → Login → MainShell con tabs; cada feature tiene su provider que llama a usecases."
- Integraciones (30s): "Supabase (auth/db), OpenWeather (clima), HuggingFace (modelo), Dio (HTTP)."
- Calidad/Mejoras (30s): "Se usa `Either` para errores; pasos siguientes: centralizar DI, migrar a Riverpod (opcional), añadir tests y CI."

## 8) Esquema de 5 diapositivas
1. Título: "EcoMora — Monitoreo de mora"
2. Arquitectura: "Presentation → Domain → Data"
3. Flujo: "main → Splash → Login → MainShell (tabs)"
4. Integraciones: "Supabase, OpenWeather, HuggingFace, Dio"
5. Riesgos & próximos pasos: "Proteger .env, centralizar DI, tests + CI"

## 9) Riesgos técnicos y recomendaciones
- `.env` podría comitearse: añadir `.env` a `.gitignore`, mantener `.env.example`.
- DI manual en `app.dart`: usar `get_it` o Riverpod para mejorar modularidad/testabilidad.
- `flutter_riverpod` aparece en `pubspec.yaml` pero no se usa — eliminar o migrar.
- Reutilizar instancia de `Dio` con interceptors para evitar duplicidad.
- Verificar reglas RLS en Supabase para seguridad por usuario.

## 10) Comandos (PowerShell) para ejecutar y testear
Preparar:
```powershell
flutter pub get
# Crear archivo .env en la raíz con SUPABASE_URL y SUPABASE_ANON_KEY
```
Ejecutar:
```powershell
flutter devices
flutter run
# o especificar device id
flutter run -d <deviceId>
flutter build apk --release
```
Tests:
```powershell
flutter test
# test específico
flutter test test/features/auth/auth_provider_test.dart
```

## 11) Pasos pre-demo
- Tener `.env` con credenciales y usuario de prueba en Supabase.
- Iniciar emulador o conectar dispositivo físico.
- Ensayar: login → predictions → abrir providers/usecases en IDE para explicar.

## 12) Análisis detallado del tab ALERTAS: cómo se conectan los archivos y flujo de datos

### Estructura completa del feature `alerts`
```
features/alerts/
├── presentation/
│   ├── providers/
│   │   └── alert_provider.dart ← Gestiona estado, llama usecases
│   ├── screens/
│   │   └── alerts_screen.dart ← UI principal (2 tabs: Activas / Historial)
│   └── widgets/
│       ├── alert_card.dart
│       └── alert_detail_widget.dart
├── domain/
│   ├── entities/
│   │   └── alert.dart ← Entidad Alert (POJO, sin modelos DB)
│   ├── repositories/
│   │   ├── alert_repository.dart ← Contrato para alertas normales
│   │   └── alert_engine_repository.dart ← Contrato para generación + persist
│   └── usecases/
│       ├── evaluate_thresholds_usecase.dart ← Genera y persiste alertas (HF)
│       ├── get_active_alerts_usecase.dart ← Obtiene no leídas y no expiradas
│       ├── get_alerts_history_usecase.dart ← Historial con filtros
│       └── mark_alert_as_read_usecase.dart ← Marca como vista
└── data/
    ├── datasources/
    │   ├── alert_remote_datasource.dart ← Supabase: fetch, insert, update
    │   └── alert_engine_remote_datasource.dart ← HuggingFace + persist
    ├── models/
    │   └── alert_model.dart ← Extensión de Alert con métodos fromJson/toJson
    └── repositories/
        ├── alert_repository_impl.dart ← Implementa AlertRepository
        └── alert_engine_repository_impl.dart ← Implementa AlertEngineRepository
```

### Flujo de datos: 2 caminos principales

#### **Camino 1: Generación + Persistencia (HuggingFace → Supabase)**
Cuándo: Usuario solicita evaluación de alertas (ejemplo: desde `home_screen` se envían features del suelo).

1. **UI → AlertProvider** (presentation/screen)
   - `AlertsScreen` o `HomeScreen` llama: `context.read<AlertProvider>().evaluateThresholds(parcelaId, features)`
   - Ejemplo de `features`: `{'pH': 6.5, 'temperatura_C': 22, 'humedad_suelo_pct': 65, 'N_ppm': 120, 'P_ppm': 50, 'K_ppm': 180}`

2. **AlertProvider → EvaluateThresholdsUseCase** (presentation/provider → domain/usecase)
   - Provider valida estado mínimo, setea `_isEvaluating = true`, llama al usecase:
     ```dart
     final result = await evaluateThresholdsUseCase(
       parcelaId: parcelaId,
       features: features,
     );
     ```
   - El usecase valida que `parcelaId` no esté vacío y que existan todas las claves en `features`.

3. **EvaluateThresholdsUseCase → AlertEngineRepository** (domain/usecase → data/repository)
   - Usecase delega al repositorio:
     ```dart
     return engineRepository.generateAndPersistAlerts(
       parcelaId: parcelaId,
       features: features,
     );
     ```

4. **AlertEngineRepositoryImpl → AlertEngineRemoteDataSource** (data/repository → data/datasource)
   - Repository envuelve la llamada en `try/catch` y retorna `Either<String, List<Alert>>`:
     ```dart
     final alerts = await remote.generateAndPersistAlerts(
       parcelaId: parcelaId,
       features: features,
     );
     ```

5. **AlertEngineRemoteDataSource → HuggingFace API + AlertRemoteDataSource** (data/datasource)
   - DataSource `alert_engine_remote_datasource.dart`:
     - Crea un POST a HuggingFace endpoint (`https://roca22-intelligent-alerts-rf.hf.space/predict`) con los features.
     - Recibe respuesta con alertas detectadas y valores de entrada.
     - Mapea la respuesta a `AlertModel` usando `AlertModel.fromRandomForestResponse()`.
     - Llama a `_alertsDb.insertAlerts(models)` para persistir en Supabase.

6. **AlertRemoteDataSource → Supabase (tabla `alertas_historial`)** (data/datasource)
   - `alert_remote_datasource.dart`, método `insertAlerts()`:
     - Ejecuta `insert()` en la tabla `alertas_historial` (en Supabase).
     - Devuelve los registros insertados como `List<AlertModel>`.

7. **Retorno (cadena inversa)** → UI actualizada
   - DataSource retorna `List<AlertModel>`.
   - Repository mapea a entidades (`List<Alert>`) y retorna `Right(alerts)`.
   - Usecase recibe el `Right` y lo propaga.
   - Provider interpreta el resultado:
     ```dart
     result.fold(
       (error) => { _status = error; notifyListeners(); },
       (alerts) => {
         _lastEvaluationAlerts = alerts;
         fetchActiveAlerts(parcelaId); // Actualiza UI con nuevas activas
       }
     );
     ```
   - UI (`AlertsScreen`) muestra las nuevas alertas en la pestaña "Activas".

---

#### **Camino 2: Obtención de alertas (desde Supabase)**
Cuándo: Usuario abre el tab de alertas o solicita refrescar.

1. **UI → AlertProvider** (presentation/screen)
   - `AlertsScreen.initState()` → `_initializeData()` → llama:
     ```dart
     context.read<AlertProvider>().fetchActiveAlerts(parcelaId);
     // o
     context.read<AlertProvider>().fetchAlertsHistory(parcelaId: parcelaId);
     ```

2. **AlertProvider → GetActiveAlertsUseCase / GetAlertsHistoryUseCase** (presentation → domain)
   - Provider setea `_status = loading`, llama al usecase apropiado.

3. **Usecase → AlertRepository** (domain → data/repository)
   - Usecase ejecuta la lógica de negocio (validaciones, filtros de severidad, ordenamiento):
     ```dart
     final result = await repository.fetchAlerts(
       parcelaId: parcelaId,
       onlyUnread: true,
       limit: limit,
     );
     // Filtra activas (no expiradas según severidad)
     final active = alerts.where((a) => a.isActive).toList();
     // Ordena: severidad desc → fecha desc
     ```

4. **AlertRepositoryImpl → AlertRemoteDataSource** (data/repository → data/datasource)
   - Repository delega al datasource:
     ```dart
     final models = await remoteDataSource.fetchAlerts(
       parcelaId: parcelaId,
       onlyUnread: true,
       limit: limit,
     );
     ```

5. **AlertRemoteDataSource → Supabase** (data/datasource)
   - Datasource construye query dinámica:
     ```dart
     var query = _supabase
       .from('alertas_historial')
       .select()
       .eq('parcela_id', parcelaId)
       .eq('vista', false)  // onlyUnread = true
       .order('fecha_alerta', ascending: false)
       .limit(limit);
     ```
   - Retorna `List<AlertModel>` con los resultados de Supabase.

6. **Retorno → UI** (cadena inversa)
   - AlertModel → Alert entity.
   - Repository retorna `Right(List<Alert>)`.
   - Usecase filtra activas (valida expiración local en base a severidad).
   - Provider recibe y actualiza `_activeAlerts = alerts`.
   - `AlertsScreen` re-renderiza con `Consumer<AlertProvider>`.

---

### Detalles clave: Transformación de datos (Models ↔ Entities)

- **AlertModel** (data layer):
  - Extiende `Alert` (es una entidad con métodos adicionales).
  - Tiene `toJson()`, `fromJson()`, `toJsonForInsert()` para Supabase.
  - Tiene `fromRandomForestResponse()` para mapear respuesta de HuggingFace.
  - En el repositorio se convierte al tipo `Alert` abstracto para el domain.

- **Alert** (domain layer):
  - POJO (Plain Old Dart Object) sin lógica de persistencia.
  - Define propiedades: `id`, `parcelaId`, `tipoAlerta`, `severidad`, `mensaje`, `fechaAlerta`, `vista`, etc.
  - Getter `isActive` valida expiración según severidad y fecha actual.

---

### Estados del AlertProvider

```
AlertStatus.initial → AlertStatus.loading → AlertStatus.success/error
└── _activeAlerts: List<Alert>
└── _alertsHistory: List<Alert>
└── _isEvaluating: bool (cuando se llama a HF)
└── _lastEvaluationAlerts: List<Alert>
└── _errorMessage: String
```

---

### Flujo visual (diagramas textuales):

**Flujo de generación (HF):**
```
HomeScreen / AlertsScreen
    ↓ evaluateThresholds(parcelaId, features)
AlertProvider (loading, isEvaluating=true)
    ↓ call EvaluateThresholdsUseCase
EvaluateThresholdsUseCase (valida features)
    ↓ call AlertEngineRepository.generateAndPersistAlerts()
AlertEngineRepositoryImpl
    ↓ call AlertEngineRemoteDataSource.generateAndPersistAlerts()
AlertEngineRemoteDataSource
    ├─→ POST a HuggingFace API (envía features)
    ├─→ Recibe alertas_detectadas
    ├─→ Mapea a AlertModel
    └─→ call _alertsDb.insertAlerts(models)
        ↓ insertAlerts() en Supabase
AlertRemoteDataSource (Supabase insert)
    ↓ retorna List<AlertModel>
AlertEngineRemoteDataSource
    ↓ retorna List<AlertModel>
AlertEngineRepositoryImpl
    ↓ retorna Right(List<Alert>)
EvaluateThresholdsUseCase
    ↓ retorna Right(List<Alert>)
AlertProvider (success, _lastEvaluationAlerts = alerts)
    ↓ fetchActiveAlerts(parcelaId) [opcional, para actualizar UI]
    ↓ [repite flujo de obtención]
AlertsScreen (Consumer) → re-renderiza con nuevas alertas
```

**Flujo de obtención (lectura):**
```
AlertsScreen (tab Activas)
    ↓ fetchActiveAlerts(parcelaId)
AlertProvider (loading=true)
    ↓ call GetActiveAlertsUseCase(parcelaId)
GetActiveAlertsUseCase
    ├─ call AlertRepository.fetchAlerts(onlyUnread=true)
    ├─ Recibe List<Alert>
    ├─ Filtra isActive (no expiradas)
    └─ Ordena por severidad desc → fecha desc
AlertRepositoryImpl
    ↓ call AlertRemoteDataSource.fetchAlerts()
AlertRemoteDataSource (Supabase)
    ├─ SELECT from alertas_historial
    │  WHERE parcela_id = ?
    │    AND vista = false
    │  ORDER BY fecha_alerta DESC
    │  LIMIT 50
    └─ retorna List<AlertModel>
AlertRepositoryImpl
    ↓ mapea AlertModel → Alert
    ↓ retorna Right(List<Alert>)
GetActiveAlertsUseCase
    ↓ retorna Right(List<Alert>)
AlertProvider (_activeAlerts = alerts, status=success)
    ↓ notifyListeners()
AlertsScreen (Consumer<AlertProvider>)
    ↓ re-renderiza ListView con AlertCard widgets
    └─ muestra tipo, severidad, mensaje, fecha
```

---

### Resumen: Flujo de datos para Alertas

| Capa | Archivo | Responsabilidad |
|------|---------|-----------------|
| **Presentation** | `alert_provider.dart` | Orquesta usecases, maneja estado (`loading`, `success`, `error`, `isEvaluating`), notifica UI |
| **Presentation** | `alerts_screen.dart` | UI: 2 tabs (Activas/Historial), dibuja AlertCard, consume AlertProvider |
| **Domain** | `alert.dart` | Entidad Alert (puro negocio, sin DB) |
| **Domain** | `evaluate_thresholds_usecase.dart` | Genera y persiste alertas (valida features, delega a engine repo) |
| **Domain** | `get_active_alerts_usecase.dart` | Obtiene alertas activas (filtra expiradas, ordena por severidad) |
| **Domain** | `get_alerts_history_usecase.dart` | Obtiene historial con filtros de fecha/tipo |
| **Domain** | `alert_repository.dart` | Contrato: `fetchAlerts()`, `insertAlerts()`, `markAlertAsRead()` |
| **Domain** | `alert_engine_repository.dart` | Contrato: `generateAndPersistAlerts()` (HF + persist) |
| **Data** | `alert_repository_impl.dart` | Implementa `AlertRepository`: delega a datasource, mapea errors |
| **Data** | `alert_engine_repository_impl.dart` | Implementa `AlertEngineRepository`: delega a HF datasource |
| **Data** | `alert_remote_datasource.dart` | Supabase: `fetch()`, `insert()`, `update()`, `markAsRead()` |
| **Data** | `alert_engine_remote_datasource.dart` | HuggingFace: POST a endpoint ML, recibe alertas, persiste via `alertsDb` |
| **Data** | `alert_model.dart` | AlertModel + conversión JSON/Entity, `fromRandomForestResponse()` |

---

### Ejemplo real: Usuario abre app → ve alertas activas

1. Usuario abre la app → `MainShellScreen` tab 2 → `AlertsScreen`.
2. `AlertsScreen.initState()` llama `_initializeData()`:
   ```dart
   // Obtiene parcelaId de ParcelaProvider
   final parcelaId = context.read<ParcelaProvider>().parcelaSeleccionada?.id;
   // Llama al provider de alertas
   context.read<AlertProvider>().fetchActiveAlerts(parcelaId);
   ```
3. `AlertProvider.fetchActiveAlerts()`:
   - Setea `_status = loading`.
   - Llama `GetActiveAlertsUseCase(parcelaId)`.
4. Usecase:
   - Llama `AlertRepository.fetchAlerts(onlyUnread: true)`.
5. Repositorio:
   - Llama `AlertRemoteDataSource.fetchAlerts()`.
6. DataSource:
   - Ejecuta query Supabase: `SELECT * FROM alertas_historial WHERE parcela_id = ? AND vista = false ORDER BY fecha_alerta DESC`.
   - Retorna `List<AlertModel>`.
7. Retorno:
   - Repository convierte modelos a entidades, retorna `Right(List<Alert>)`.
   - Usecase filtra activas y ordena.
   - Provider recibe, setea `_activeAlerts = alerts`, notifica UI.
8. UI (`AlertsScreen`):
   - `Consumer<AlertProvider>` recibe actualización.
   - `_buildActiveTab()` renderiza `ListView` de `AlertCard` con cada alerta.
   - Usuario ve: "pH muy ácido (Crítica)", "Temperatura alta (Alta)", etc.

---

### Cómo se inyectan dependencias en `app.dart`

En `lib/app.dart`, dentro de `EcoMoraApp.build()`:
```dart
// ===== ALERTS PROVIDER =====
ChangeNotifierProvider(
  create: (_) {
    final dio = Dio();
    
    // 1. Crear datasources
    final alertsDb = AlertRemoteDataSource();
    final engineDs = AlertEngineRemoteDataSource(dio: dio, alertsDb: alertsDb);
    
    // 2. Crear repositorios
    final alertsRepository = AlertRepositoryImpl(remoteDataSource: alertsDb);
    final engineRepository = AlertEngineRepositoryImpl(remote: engineDs);
    
    // 3. Crear usecases
    final evaluateThresholdsUseCase = EvaluateThresholdsUseCase(engineRepository);
    final getActiveAlertsUseCase = GetActiveAlertsUseCase(alertsRepository);
    final getAlertsHistoryUseCase = GetAlertsHistoryUseCase(alertsRepository);
    final markAlertAsReadUseCase = MarkAlertAsReadUseCase(alertsRepository);
    
    // 4. Crear provider con usecases inyectados
    return AlertProvider(
      evaluateThresholdsUseCase: evaluateThresholdsUseCase,
      getActiveAlertsUseCase: getActiveAlertsUseCase,
      getAlertsHistoryUseCase: getAlertsHistoryUseCase,
      markAlertAsReadUseCase: markAlertAsReadUseCase,
    );
  },
),
```

Esto asegura que **cuando la app arranca, todos los componentes están disponibles y conectados globalmente**.

---


