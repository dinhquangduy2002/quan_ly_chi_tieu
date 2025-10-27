// File: lib/features/transactions/presentation/pages/transactions_list_page.dart

import 'package:flutter/material.dart';
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
  final DateTime today = DateTime.now();
  final GetTransactions _getTransactions = GetTransactions(TransactionRepositoryImpl());
  final DeleteTransaction _deleteTransaction = DeleteTransaction(TransactionRepositoryImpl());

  List<TransactionEntity> _transactions = [];
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

    setState(() {
      _isLoading = true;
    });

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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSafeSnackBar(String message, {bool isError = false}) {
    if (_isDisposed || !mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? AppColors.error : AppColors.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _deleteTransactionById(String id) async {
    try {
      await _deleteTransaction(id);
      await _loadTransactions();

      _showSafeSnackBar('Đã xóa giao dịch thành công');

    } catch (e) {
      _showSafeSnackBar('Lỗi khi xóa giao dịch: $e', isError: true);
    }
  }

  // Tính tổng thu nhập và chi tiêu từ dữ liệu thực
  double get _monthlyExpenseTotal {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, transaction) => sum + transaction.amount.abs());
  }

  double get _monthlyIncomeTotal {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  Map<DateTime, List<TransactionEntity>> get _groupedTransactions {
    final Map<DateTime, List<TransactionEntity>> grouped = {};
    for (var transaction in _transactions) {
      final date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return {
      for (var key in sortedKeys) key: grouped[key]!
    };
  }

  // Các phương thức format giữ nguyên
  String _formatAmount(double amount) {
    return amount.abs().toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _navigateToCreateTransaction() {
    if (_isDisposed || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionsFormPage(
          onSuccess: _loadTransactions,
        ),
      ),
    );
  }

  void _navigateToEditTransaction(TransactionEntity transaction) {
    if (_isDisposed || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionsFormPage(
          transaction: transaction,
          onSuccess: _loadTransactions,
        ),
      ),
    );
  }

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
            _buildSearchBox(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _groupedTransactions.isEmpty
                  ? _buildEmptyState()
                  : _buildGroupedTransactionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (!_isDisposed && mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              const Text(
                'Thu - chi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
          _buildSummaryItem(
              label: 'Tiền chi',
              amount: _monthlyExpenseTotal,
              color: AppColors.error
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.border,
          ),
          _buildSummaryItem(
              label: 'Tiền thu',
              amount: _monthlyIncomeTotal,
              color: AppColors.success
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({required String label, required double amount, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatAmount(amount),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilter() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Tháng này',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Icon(Icons.search, color: AppColors.textLight),
          const SizedBox(width: 12),
          Text(
            'Tìm giao dịch',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedTransactionList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _groupedTransactions.length,
      itemBuilder: (context, index) {
        final date = _groupedTransactions.keys.elementAt(index);
        final transactions = _groupedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _formatDateHeader(date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ...transactions.map((t) => InkWell(
              onTap: () => _showTransactionDetail(t),
              child: _buildTransactionItem(t),
            )).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(TransactionEntity transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final Color amountColor = isIncome ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              transaction.icon,
              color: transaction.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  transaction.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : ''}${_formatAmount(transaction.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Hôm nay';
    }
    return _formatDate(date);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có giao dịch nào',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(TransactionEntity transaction) {
    if (_isDisposed || !mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Chi tiết ${transaction.type == TransactionType.income ? 'thu nhập' : 'chi tiêu'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildTransactionDetailItem(transaction),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        label: const Text(
                          'Xóa',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (!_isDisposed && mounted) {
                            _showDeleteConfirmation(transaction);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        label: const Text(
                          'Chỉnh sửa',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (!_isDisposed && mounted) {
                            _navigateToEditTransaction(transaction);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionDetailItem(TransactionEntity transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final Color amountColor = isIncome ? AppColors.success : AppColors.textPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: transaction.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                transaction.category,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDate(transaction.date),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${isIncome ? '+' : ''}${_formatAmount(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmation(TransactionEntity transaction) {
    if (_isDisposed || !mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 40),
          content: Text(
            'Bạn có chắc muốn xóa giao dịch "${transaction.title}" này không?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Quay lại', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (!_isDisposed && mounted) {
                  _deleteTransactionById(transaction.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}