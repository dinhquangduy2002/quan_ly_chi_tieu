import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../transactions/data/repositories/transaction_repository_impl.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/usecases/get_transactions.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final GetTransactions _getTransactions =
  GetTransactions(TransactionRepositoryImpl());

  bool _isLoading = true;
  List<TransactionEntity> _allTransactions = [];
  List<TransactionEntity> _filteredTransactions = [];

  double _totalIncome = 0;
  double _totalExpense = 0;

  // Biến để lọc theo tháng
  DateTime _selectedMonth = DateTime.now();
  List<DateTime> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final transactions = await _getTransactions();
      setState(() {
        _allTransactions = transactions;
        _updateAvailableMonths();
        _applyMonthFilter(_selectedMonth); // Mặc định chọn tháng hiện tại
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _updateAvailableMonths() {
    final months = <DateTime>{};

    for (var transaction in _allTransactions) {
      final year = transaction.date.year;
      final month = transaction.date.month;
      months.add(DateTime(year, month));
    }

    // Thêm tháng hiện tại nếu chưa có
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    months.add(currentMonth);

    // Sắp xếp các tháng từ mới nhất đến cũ nhất
    _availableMonths = months.toList()
      ..sort((a, b) => b.compareTo(a));
  }

  void _applyMonthFilter(DateTime selectedMonth) {
    setState(() {
      _selectedMonth = selectedMonth;

      // Lọc theo tháng được chọn
      _filteredTransactions = _allTransactions.where((transaction) {
        return transaction.date.year == selectedMonth.year &&
            transaction.date.month == selectedMonth.month;
      }).toList();

      _calculateTotals();
    });
  }

  void _calculateTotals() {
    double income = 0;
    double expense = 0;
    for (var t in _filteredTransactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    _totalIncome = income;
    _totalExpense = expense;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Thống kê',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Danh sách tháng để lọc
              _buildMonthFilter(),
              const SizedBox(height: 20),
              _buildSummaryCards(),
              const SizedBox(height: 30),
              _buildBarChartSection(),
              const SizedBox(height: 50),
              _buildPieChartSection(),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Danh sách tháng để lọc (hiển thị ngang)
  Widget _buildMonthFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn tháng:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Các tháng có dữ liệu
              ..._availableMonths.map((month) => _buildMonthFilterChip(
                label: '${month.month}/${month.year}',
                isSelected: _selectedMonth.year == month.year &&
                    _selectedMonth.month == month.month,
                onTap: () => _applyMonthFilter(month),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Tổng thu – chi
  Widget _buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Tổng thu', _totalIncome, AppColors.success),
        _buildStatCard('Tổng chi', _totalExpense, AppColors.error),
        _buildStatCard(
          'Số dư',
          _totalIncome - _totalExpense,
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              '${amount.toStringAsFixed(0)} VND',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Biểu đồ cột thu – chi theo tháng
  Widget _buildBarChartSection() {
    final monthData = _groupByMonth();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biểu đồ thu - chi tháng ${_selectedMonth.month}/${_selectedMonth.year}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: monthData.entries.map((e) {
                final month = e.key;
                final income = e.value['income']!;
                final expense = e.value['expense']!;
                return BarChartGroupData(
                  x: month,
                  barRods: [
                    BarChartRodData(
                      toY: income,
                      color: AppColors.success,
                      width: 10,
                    ),
                    BarChartRodData(
                      toY: expense,
                      color: AppColors.error,
                      width: 10,
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) =>
                        Text('T${value.toInt()}', style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  Map<int, Map<String, double>> _groupByMonth() {
    final Map<int, Map<String, double>> monthData = {};

    // Chỉ hiển thị tháng đang được chọn
    final month = _selectedMonth.month;
    monthData[month] = {'income': 0, 'expense': 0};

    for (var t in _filteredTransactions) {
      if (t.type == TransactionType.income) {
        monthData[month]!['income'] = monthData[month]!['income']! + t.amount;
      } else {
        monthData[month]!['expense'] = monthData[month]!['expense']! + t.amount;
      }
    }

    return monthData;
  }

  // 🔹 Biểu đồ tròn chi tiêu theo danh mục
  Widget _buildPieChartSection() {
    final expenseByCategory = _groupByCategory(TransactionType.expense);

    if (expenseByCategory.isEmpty) {
      return const Center(
        child: Text('Chưa có dữ liệu chi tiêu để hiển thị.'),
      );
    }

    final total = expenseByCategory.values.fold(0.0, (sum, e) => sum + e);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tỷ lệ chi tiêu tháng ${_selectedMonth.month}/${_selectedMonth.year}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 50,
                sections: expenseByCategory.entries.map((e) {
                  final percent = (e.value / total) * 100;
                  final color = Colors.primaries[
                  expenseByCategory.keys.toList().indexOf(e.key) %
                      Colors.primaries.length];
                  return PieChartSectionData(
                    value: e.value,
                    color: color,
                    title: '${percent.toStringAsFixed(0)}%',
                    radius: 70,
                    titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...expenseByCategory.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                color: Colors.primaries[
                expenseByCategory.keys.toList().indexOf(e.key) %
                    Colors.primaries.length],
              ),
              const SizedBox(width: 8),
              Text(
                '${e.key}: ${e.value.toStringAsFixed(0)} VND',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Map<String, double> _groupByCategory(TransactionType type) {
    final map = <String, double>{};
    for (var t in _filteredTransactions.where((e) => e.type == type)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }
}