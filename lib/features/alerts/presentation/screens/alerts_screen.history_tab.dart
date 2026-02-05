part of 'alerts_screen.dart';

extension _AlertsScreenHistoryUI on _AlertsScreenState {
  Widget _buildHistoryTab() {
    return Consumer<AlertProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            _buildFilterBar(provider),
            Expanded(child: _buildHistoryList(provider)),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(AlertProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildFilterChip(
                label: 'Hoy',
                isSelected: provider.currentFilter == DateFilter.today,
                onTap: () => _applyFilter(DateFilter.today),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Semana',
                isSelected: provider.currentFilter == DateFilter.week,
                onTap: () => _applyFilter(DateFilter.week),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Mes',
                isSelected: provider.currentFilter == DateFilter.month,
                onTap: () => _applyFilter(DateFilter.month),
              ),
              const SizedBox(width: 8),
              _buildCalendarButton(provider),
            ],
          ),
          if (provider.currentFilter != DateFilter.all) ...[
            const SizedBox(height: 12),
            _buildActiveFilterIndicator(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarButton(AlertProvider provider) {
    return InkWell(
      onTap: () => _showCalendarPicker(provider),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: provider.currentFilter == DateFilter.custom
              ? const Color(0xFF6A1B9A)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.calendar_today,
          size: 16,
          color: provider.currentFilter == DateFilter.custom
              ? Colors.white
              : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildActiveFilterIndicator(AlertProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_alt, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 6),
          Text(
            'Filtrado por: ${provider.filterDescription}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: _clearFilters,
            child: Icon(Icons.close, size: 16, color: Colors.blue[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(AlertProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return _buildErrorState(provider.errorMessage);
    }

    if (!provider.hasHistory) {
      return _buildEmptyHistoryState();
    }

    final parcelaId = _parcelaId;
    if (parcelaId == null) {
      return _buildNoParcelaState();
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshHistory(parcelaId),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: provider.groupedByDate.length,
        itemBuilder: (context, index) {
          final date = provider.groupedByDate.keys.elementAt(index);
          final alerts = provider.groupedByDate[date]!;
          return _buildDateGroup(date, alerts);
        },
      ),
    );
  }

  Widget _buildDateGroup(String date, List<Alert> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...alerts.map(_buildAlertCard), // usa el mismo _buildAlertCard del otro part
        const SizedBox(height: 8),
      ],
    );
  }
}
