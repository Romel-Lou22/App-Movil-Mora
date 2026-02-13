part of 'alerts_screen.dart';

extension _AlertsScreenActiveTab on _AlertsScreenState {
Widget _buildActiveTab() {
return Consumer<AlertProvider>(
builder: (context, provider, child) {
if (provider.isLoading) {
return const Center(child: CircularProgressIndicator());
}
if (provider.hasError) {
return _buildErrorState(provider.errorMessage);
}
if (!provider.hasActiveAlerts) {
return _buildEmptyActiveState();
}

final parcelaId = _parcelaId;
if (parcelaId == null) {
return _buildNoParcelaState();
}

return RefreshIndicator(
onRefresh: () => provider.refreshActiveAlerts(parcelaId),
child: _buildActiveAlertsList(provider),
);
},
);
}

Widget _buildActiveAlertsList(AlertProvider provider) {
// ✅ Ordenamos por created_at (fecha de creación real) descendente
final sortedAlerts = List<Alert>.from(provider.activeAlerts);
sortedAlerts.sort((a, b) {
// Usar createdAt en lugar de fechaAlerta para mejor precisión
return b.createdAt.compareTo(a.createdAt);
});

// Función helper para obtener la clave de severidad
String sev(Alert a) => _sevKey(a.severidad);

// Agrupamos por fecha de creación (solo fecha, sin hora)
final Map<String, List<Alert>> alertsByDate = {};

for (final alert in sortedAlerts) {
// ✅ Usar createdAt para agrupar
final date = alert.createdAt;
final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

alertsByDate.putIfAbsent(dateKey, () => []);
alertsByDate[dateKey]!.add(alert);
}

// Obtenemos las fechas ordenadas (más recientes primero)
final sortedDates = alertsByDate.keys.toList()
..sort((a, b) => b.compareTo(a));

return ListView(
padding: const EdgeInsets.symmetric(vertical: 16),
children: [
// Iteramos por cada fecha (bloque de alertas)
for (final dateKey in sortedDates) ...[
_buildDateSection(dateKey, alertsByDate[dateKey]!),
],
],
);
}

Widget _buildDateSection(String dateKey, List<Alert> alerts) {
String sev(Alert a) => _sevKey(a.severidad);

// Separamos por severidad DENTRO de este bloque de fecha
final critical = alerts.where((a) => sev(a) == 'critica').toList();
final medium = alerts.where((a) => sev(a) == 'alta' || sev(a) == 'media').toList();
final low = alerts.where((a) => sev(a) == 'baja').toList();

// Si no hay alertas de ningún tipo, no mostrar nada
if (critical.isEmpty && medium.isEmpty && low.isEmpty) {
return const SizedBox.shrink();
}

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Mostramos la fecha como encabezado
Padding(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
child: Row(
children: [
Icon(
Icons.calendar_today,
size: 16,
color: const Color(0xFF6B7280),
),
const SizedBox(width: 8),
Text(
_formatDateHeader(dateKey),
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.w600,
color: Color(0xFF374151),
letterSpacing: 0.2,
),
),
],
),
),
const SizedBox(height: 8),

// Críticas primero
if (critical.isNotEmpty) ...[
_buildSeveritySection(
title: 'Críticas',
icon: Icons.error,
color: const Color(0xFFDC2626),
count: critical.length,
alerts: critical,
),
if (medium.isNotEmpty || low.isNotEmpty)
const SizedBox(height: 12),
],

// Altas/Medias después
if (medium.isNotEmpty) ...[
_buildSeveritySection(
title: 'Altas/Medias',
icon: Icons.warning_amber_rounded,
color: const Color(0xFFF59E0B),
count: medium.length,
alerts: medium,
),
if (low.isNotEmpty)
const SizedBox(height: 12),
],

// Bajas al final
if (low.isNotEmpty) ...[
_buildSeveritySection(
title: 'Bajas',
icon: Icons.info_outline,
color: const Color(0xFF3B82F6),
count: low.length,
alerts: low,
),
],

// Separador entre bloques de fechas (solo si no es el último)
const SizedBox(height: 16),
const Padding(
padding: EdgeInsets.symmetric(horizontal: 16),
child: Divider(height: 1, thickness: 1),
),
const SizedBox(height: 16),
],
);
}

String _formatDateHeader(String dateKey) {
try {
final parts = dateKey.split('-');
if (parts.length != 3) return dateKey;

final date = DateTime(
int.parse(parts[0]),
int.parse(parts[1]),
int.parse(parts[2]),
);

final now = DateTime.now();
final today = DateTime(now.year, now.month, now.day);
final yesterday = today.subtract(const Duration(days: 1));
final alertDate = DateTime(date.year, date.month, date.day);

if (alertDate == today) {
return 'Hoy - ${date.day} de ${_getMonthName(date.month)}';
} else if (alertDate == yesterday) {
return 'Ayer - ${date.day} de ${_getMonthName(date.month)}';
} else {
// Formato: "12 de Febrero, 2026"
return '${date.day} de ${_getMonthName(date.month)}, ${date.year}';
}
} catch (e) {
return dateKey;
}
}

String _getMonthName(int month) {
const months = [
'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
];
return months[month - 1];
}

Widget _buildSeveritySection({
required String title,
required IconData icon,
required Color color,
required int count,
required List<Alert> alerts,
}) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.symmetric(horizontal: 16),
child: Row(
children: [
Icon(icon, color: color, size: 20),
const SizedBox(width: 8),
Text(
title,
style: TextStyle(
fontSize: 15,
fontWeight: FontWeight.w600,
color: color,
),
),
const SizedBox(width: 6),
Container(
padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
decoration: BoxDecoration(
color: color.withOpacity(0.15),
borderRadius: BorderRadius.circular(10),
),
child: Text(
count.toString(),
style: TextStyle(
fontSize: 13,
fontWeight: FontWeight.w700,
color: color,
),
),
),
],
),
),
const SizedBox(height: 8),
...alerts.map(_buildAlertCard),
],
);
}

Widget _buildAlertCard(Alert alert) {
final weather = context.watch<WeatherProvider>().weather;

return AlertCard(
alert: alert,
onTap: () => _showAlertDetail(alert),
onMarkAsRead: () => _markAlertAsRead(alert),
temperature: weather?.temperature,
humidity: weather?.humidity,
);
}

/// Convierte severidad (String / enum / Object) a un key normalizado.
String _sevKey(Object? value) {
if (value == null) return 'baja';

// Si es String directo
if (value is String) {
final normalized = value.toLowerCase().trim();
if (normalized == 'crítica' || normalized == 'critica') return 'critica';
if (normalized == 'media' || normalized == 'medium') return 'media';
if (normalized == 'alta' || normalized == 'high') return 'alta';
if (normalized == 'baja' || normalized == 'low') return 'baja';
return normalized;
}

// Si es enum (AlertSeverity.critica, etc.)
final raw = value.toString();
final last = raw.contains('.') ? raw.split('.').last : raw;
final normalized = last.toLowerCase().trim();

if (normalized == 'crítica' || normalized == 'critica') return 'critica';
if (normalized == 'media' || normalized == 'medium') return 'media';
if (normalized == 'alta' || normalized == 'high') return 'alta';
if (normalized == 'baja' || normalized == 'low') return 'baja';

return normalized;
}
}