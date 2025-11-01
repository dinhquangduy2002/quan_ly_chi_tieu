import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../../transactions/data/repositories/transaction_repository_impl.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/usecases/get_transactions.dart';
import 'home_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetTransactions _getTransactions = GetTransactions(TransactionRepositoryImpl());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double _totalBalance = 0;
  String _selectedType = 'Chi';
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();

  List<TransactionEntity> _allTransactions = [];
  List<TransactionEntity> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _getTransactions();
      setState(() {
        _allTransactions = transactions;
        _calculateWalletData();
        _filterTransactions();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading transactions: $e');
      setState(() => _isLoading = false);
    }
  }
  // Tính toán số dư
  void _calculateWalletData() {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var transaction in _allTransactions) {
      // Không lọc tháng nữa — lấy toàn bộ giao dịch
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpense += transaction.amount;
      }
    }

    setState(() {
      _totalBalance = totalIncome - totalExpense;
    });
  }

  void _filterTransactions() {
    final filtered = _allTransactions
        .where((transaction) =>
    transaction.date.month == _selectedMonth.month &&
        transaction.date.year == _selectedMonth.year &&
        (_selectedType == 'Chi'
            ? transaction.type == TransactionType.expense
            : transaction.type == TransactionType.income))
        .toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _filteredTransactions = filtered.take(4).toList();
    });
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
      locale: const Locale('vi', 'VN'),
    );

    if (result != null) {
      setState(() {
        _selectedMonth = DateTime(result.year, result.month);
        _filterTransactions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background.withOpacity(0.97),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTotalBalanceSection(),
              const SizedBox(height: 24),
              Divider(color: AppColors.border.withOpacity(0.4)),
              const SizedBox(height: 12),
              _buildRecentTransactionsHeader(),
              const SizedBox(height: 16),
              _buildTransactionListOrEmptyState(),
              const SizedBox(height: 24),
              Divider(color: AppColors.border.withOpacity(0.4)),
              const SizedBox(height: 16),
              _buildChartHeader(), // dòng "Biểu đồ thu - chi" + lọc tháng
              const SizedBox(height: 30),
              _buildPieChartsSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
  String get _userName {
    final user = _auth.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    return user?.email?.split('@').first ?? 'User';
  }
  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.primary,
          child: Text(
            _userName[0].toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Xin chào,',
                  style:
                  TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              Text(
                _userName,
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.search, color: AppColors.textPrimary, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeSearchPage()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined,
              color: AppColors.textPrimary, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTotalBalanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Số dư ví hiện có',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_totalBalance.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              Text('VND',
                  style:
                  TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTabButton('Chi', _selectedType == 'Chi'),
              const SizedBox(width: 12),
              _buildTabButton('Thu', _selectedType == 'Thu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = label;
            _filterTransactions();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.9),
                AppColors.primary
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Biểu đồ thu - chi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.calendar_month, color: AppColors.primary),
          onPressed: _pickMonth,
        ),
        Text(
          '${_selectedMonth.month}/${_selectedMonth.year}',
          style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPieChartsSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final incomeGroups = _groupByCategory(TransactionType.income);
    final expenseGroups = _groupByCategory(TransactionType.expense);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDetailedPieChart('Chi', expenseGroups, AppColors.error),
        _buildDetailedPieChart('Thu', incomeGroups, AppColors.success),
      ],
    );
  }

  Map<String, double> _groupByCategory(TransactionType type) {
    final map = <String, double>{};
    for (var t in _allTransactions.where((e) =>
    e.type == type &&
        e.date.month == _selectedMonth.month &&
        e.date.year == _selectedMonth.year)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Widget _buildDetailedPieChart(
      String title, Map<String, double> data, Color baseColor) {
    final total = data.values.fold(0.0, (sum, v) => sum + v);
    if (total == 0) {
      return Column(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child:
            const Icon(Icons.pie_chart_outline, color: Colors.grey, size: 50),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const Text('Chưa có dữ liệu',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      );
    }

    final colors = [
      baseColor,
      baseColor.withOpacity(0.8),
      baseColor.withOpacity(0.6),
      baseColor.withOpacity(0.4),
      baseColor.withOpacity(0.2),
    ];

    int i = 0;
    final sections = data.entries.map((entry) {
      final percent = (entry.value / total) * 100;
      final c = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: c,
        value: entry.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: 35,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 1,
              centerSpaceRadius: 35,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        Text('${total.toStringAsFixed(0)} VND',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        ...data.entries.map((e) => Text(
          '${e.key}: ${e.value.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        )),
      ],
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Giao dịch ${_selectedType.toLowerCase()} gần đây',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        TextButton(
          onPressed: () {},
          child: Text('Xem thêm',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildTransactionListOrEmptyState() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredTransactions.isEmpty) {
      return _buildEmptyTransactionsState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _filteredTransactions
            .map((transaction) => Column(
          children: [
            _buildTransactionItem(transaction),
            if (transaction !=
                _filteredTransactions.last) // kẻ ngang ngăn từng dòng
              Divider(color: AppColors.border.withOpacity(0.3)),
          ],
        ))
            .toList(),
      ),
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 40),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.sentiment_dissatisfied,
                size: 60, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text('Chưa có giao dịch ${_selectedType.toLowerCase()} gần đây',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionEntity transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final Color amountColor =
    isIncome ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(transaction.icon,
                color: transaction.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                Text(transaction.category,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: amountColor),
              ),
              Text('${transaction.date.day}/${transaction.date.month}',
                  style:
                  TextStyle(fontSize: 12, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}
