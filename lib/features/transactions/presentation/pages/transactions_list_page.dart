// File: lib/features/transactions/presentation/pages/transactions_list_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transactions_form_page.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../data/repositories/transaction_repository_impl.dart';

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({super.key});

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  final GetTransactions _getTransactions = GetTransactions(TransactionRepositoryImpl());
  final DeleteTransaction _deleteTransaction = DeleteTransaction(TransactionRepositoryImpl());

  List<TransactionEntity> _transactions = [];
  String _searchKeyword = '';
  String? _selectedCategory;
  DateTime _selectedMonth = DateTime.now();

  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    if (_isDisposed || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final transactions = await _getTransactions();
      if (!_isDisposed && mounted) {
        setState(() {
          _transactions = transactions;
          _error = null;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _error = 'Lỗi khi tải dữ liệu: $e';
        });
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTransactionById(String id) async {
    try {
      await _deleteTransaction(id);
      await _loadTransactions();
      _showSnack('Đã xóa giao dịch thành công');
    } catch (e) {
      _showSnack('Lỗi khi xóa giao dịch: $e', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  // --- FILTERED DATA --- //
  List<TransactionEntity> get _filteredTransactions {
    return _transactions.where((transaction) {
      final matchMonth = transaction.date.year == _selectedMonth.year &&
          transaction.date.month == _selectedMonth.month;

      final matchKeyword = transaction.title
          .toLowerCase()
          .contains(_searchKeyword.toLowerCase());

      final matchCategory = _selectedCategory == null ||
          _selectedCategory == 'Tất cả' ||
          transaction.category == _selectedCategory;

      return matchMonth && matchKeyword && matchCategory;
    }).toList();
  }

  Map<DateTime, List<TransactionEntity>> get _groupedTransactions {
    final Map<DateTime, List<TransactionEntity>> grouped = {};
    for (var transaction in _filteredTransactions) {
      final date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(transaction);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  // --- BUILD UI --- //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            _buildMonthlySummary(),
            _buildTimeFilter(),
            _buildSearchAndFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _groupedTransactions.isEmpty
                  ? _buildEmptyState()
                  : _buildGroupedTransactionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          SizedBox(width: 48),
          Text(
            'Thu - chi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary() {
    double totalIncome = _filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
    double totalExpense = _filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount.abs());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
      transform: Matrix4.translationValues(0, -20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Tiền chi', totalExpense, AppColors.error),
          Container(width: 1, height: 50, color: AppColors.border),
          _buildSummaryItem('Tiền thu', totalIncome, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          amount.toStringAsFixed(0),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildTimeFilter() {
    final now = DateTime.now();
    final isThisMonth = _selectedMonth.month == now.month && _selectedMonth.year == now.year;
    final label = isThisMonth ? 'Tháng này' : DateFormat('MM/yyyy').format(_selectedMonth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: GestureDetector(
        onTap: _pickMonth,
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      helpText: 'Chọn tháng và năm',
    );
    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
    }
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Tìm theo tên giao dịch',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (value) => setState(() => _searchKeyword = value),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _showCategoryFilter,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.filter_list, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilter() {
    final categories = {
      'Tất cả',
      ..._transactions.map((t) => t.category).toSet()
    }.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lọc theo danh mục',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            ...categories.map((cat) => ListTile(
              title: Text(cat),
              trailing: _selectedCategory == cat
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _selectedCategory = cat);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedTransactionList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: _groupedTransactions.entries.map((entry) {
        final date = entry.key;
        final list = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...list.map(_buildTransactionItem),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTransactionItem(TransactionEntity t) {
    final isIncome = t.type == TransactionType.income;
    return ListTile(
      leading: Icon(t.icon, color: t.color),
      title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(t.category),
      trailing: Text(
        '${isIncome ? '+' : '-'}${t.amount.abs().toStringAsFixed(0)}',
        style: TextStyle(
          color: isIncome ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('Không có giao dịch nào'),
    );
  }
}
