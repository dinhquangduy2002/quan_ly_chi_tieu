// File: lib/features/transactions/presentation/pages/transactions_form_page.dart
import 'package:flutter/material.dart';
import '../../../../core/presentation/theme/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../data/repositories/transaction_repository_impl.dart';

class TransactionsFormPage extends StatefulWidget {
  final TransactionEntity? transaction;
  final Function()? onSuccess;

  const TransactionsFormPage({
    super.key,
    this.transaction,
    this.onSuccess,
  });

  @override
  State<TransactionsFormPage> createState() => _TransactionsFormPageState();
}

class _TransactionsFormPageState extends State<TransactionsFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late String _selectedCategory;
  late TransactionType _selectedType;
  late DateTime _selectedDate;
  late Color _selectedColor;
  late IconData _selectedIcon;

  final CreateTransaction _createTransaction = CreateTransaction(TransactionRepositoryImpl());
  final UpdateTransaction _updateTransaction = UpdateTransaction(TransactionRepositoryImpl());
  final DeleteTransaction _deleteTransactionUseCase = DeleteTransaction(TransactionRepositoryImpl()); // Đổi tên

  bool _isLoading = false;

  // Dữ liệu mock
  final List<String> _categories = [
    'Chi tiêu hàng ngày',
    'Đào tạo',
    'Tiết kiệm',
    'Hưởng thụ',
    'Công ty ABC',
    'Thu khác',
  ];

  final List<IconData> _icons = [
    Icons.shopping_bag,
    Icons.school,
    Icons.savings,
    Icons.travel_explore,
    Icons.work,
    Icons.sell,
    Icons.favorite,
    Icons.restaurant,
    Icons.local_hospital,
  ];

  final List<Color> _colors = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.pinkAccent,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.brown,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();

    final isEditing = widget.transaction != null;
    final transaction = widget.transaction;

    _titleController = TextEditingController(text: transaction?.title ?? '');
    _amountController = TextEditingController(
        text: transaction?.amount.abs().toStringAsFixed(0) ?? ''
    );
    _noteController = TextEditingController(text: transaction?.note ?? '');

    _selectedType = transaction?.type ?? TransactionType.expense;
    _selectedDate = transaction?.date ?? DateTime.now();
    _selectedCategory = transaction?.category ?? _categories[0];
    _selectedColor = transaction?.color ?? Colors.purple;
    _selectedIcon = transaction?.icon ?? Icons.shopping_bag;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.transaction != null;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final transaction = TransactionEntity(
          id: _isEditing ? widget.transaction!.id : '',
          title: _titleController.text,
          category: _selectedCategory,
          amount: _selectedType == TransactionType.expense
              ? -double.parse(_amountController.text)
              : double.parse(_amountController.text),
          type: _selectedType,
          date: _selectedDate,
          icon: _selectedIcon,
          color: _selectedColor,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
          userId: 'current_user_id',
          createdAt: _isEditing ? widget.transaction!.createdAt : DateTime.now(),
        );

        if (_isEditing) {
          await _updateTransaction(transaction);
        } else {
          await _createTransaction(transaction);
        }

        // Kiểm tra mounted trước khi hiển thị SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Cập nhật giao dịch thành công!' : 'Tạo giao dịch thành công!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        widget.onSuccess?.call();
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        // Kiểm tra mounted trước khi hiển thị lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary,
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Đổi tên phương thức thành _performDelete
  Future<void> _performDelete() async {
    if (!_isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 40),
        content: Text(
          'Bạn có chắc muốn xóa giao dịch "${_titleController.text}" này không?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('HUỶ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('XÓA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _deleteTransactionUseCase(widget.transaction!.id);

        // Kiểm tra mounted trước khi hiển thị SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa giao dịch thành công'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }

        widget.onSuccess?.call();
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        // Kiểm tra mounted trước khi hiển thị lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa giao dịch: $e'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Chỉnh sửa thu - chi' : 'Tạo thu - chi mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isLoading ? null : _performDelete, // Sử dụng tên mới
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildAmountAndTypeSection(),
                    const SizedBox(height: 20),

                    _buildTitleField(),
                    const SizedBox(height: 16),

                    _buildCategoryField(),
                    const SizedBox(height: 16),

                    _buildDateField(),
                    const SizedBox(height: 16),

                    _buildIconColorSelector(),
                    const SizedBox(height: 16),

                    _buildNoteField(),
                  ],
                ),
              ),

              // Nút Lưu/Cập nhật
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildSubmitButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC WIDGET HỖ TRỢ HIỆU ỨNG GIAO DIỆN ---

  // Input Decoration với VIỀN MỜ
  final InputDecoration _customInputDecoration = InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.border.withOpacity(0.8), width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.border.withOpacity(0.8), width: 1.5),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.primary, width: 2.5),
    ),
    labelStyle: TextStyle(color: AppColors.textSecondary),
    hintStyle: TextStyle(color: AppColors.textLight),
  );

  // Widget để thêm BoxShadow
  Widget _buildShadowContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withOpacity(0.5),
            blurRadius: 3,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: child,
    );
  }

  // --- CÁC WIDGET FORM CÒN LẠI ---

  Widget _buildAmountAndTypeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeSelector(),
          const SizedBox(height: 16),
          Text(
            _selectedType == TransactionType.expense ? 'Số tiền chi' : 'Số tiền thu',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          TextFormField(
            controller: _amountController,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _selectedType == TransactionType.expense ? AppColors.error : AppColors.success,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight.withOpacity(0.5),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixText: 'VND',
              suffixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số tiền';
              }
              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                return 'Số tiền không hợp lệ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = TransactionType.expense;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedType == TransactionType.expense ? AppColors.error : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _selectedType == TransactionType.expense ? AppColors.error : AppColors.border.withOpacity(0.5),
              ),
            ),
            child: Text(
              'Chi tiêu',
              style: TextStyle(
                color: _selectedType == TransactionType.expense ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedType = TransactionType.income;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedType == TransactionType.income ? AppColors.success : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _selectedType == TransactionType.income ? AppColors.success : AppColors.border.withOpacity(0.5),
              ),
            ),
            child: Text(
              'Thu nhập',
              style: TextStyle(
                color: _selectedType == TransactionType.income ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return _buildShadowContainer(
      child: TextFormField(
        controller: _titleController,
        decoration: _customInputDecoration.copyWith(
          labelText: 'Tiêu đề',
          prefixIcon: const Icon(Icons.title),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập tiêu đề';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryField() {
    return _buildShadowContainer(
      child: InkWell(
        onTap: _showCategoryPicker,
        child: InputDecorator(
          decoration: _customInputDecoration.copyWith(
            labelText: 'Danh mục',
            prefixIcon: Icon(_selectedIcon, color: _selectedColor),
          ),
          child: Text(
            _selectedCategory,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn Danh mục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return ListTile(
                      title: Text(category),
                      trailing: _selectedCategory == category ? const Icon(Icons.check, color: AppColors.primary) : null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateField() {
    return _buildShadowContainer(
      child: InkWell(
        onTap: _selectDate,
        child: InputDecorator(
          decoration: _customInputDecoration.copyWith(
            labelText: 'Ngày',
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildIconColorSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildShadowContainer(
            child: DropdownButtonFormField<IconData>(
              value: _selectedIcon,
              decoration: _customInputDecoration.copyWith(
                labelText: 'Biểu tượng',
              ),
              items: _icons.map((icon) {
                return DropdownMenuItem<IconData>(
                  value: icon,
                  child: Row(
                    children: [
                      Icon(icon, color: _selectedColor),
                      const SizedBox(width: 8),
                      Text(_getIconName(icon)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedIcon = value;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildShadowContainer(
            child: DropdownButtonFormField<int>(
              value: _selectedColor.value, // Sử dụng giá trị int của Color
              decoration: _customInputDecoration.copyWith(
                labelText: 'Màu sắc',
              ),
              items: _colors.map((color) {
                return DropdownMenuItem<int>(
                  value: color.value, // Sử dụng color value làm identifier
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_getColorName(color)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedColor = Color(value);
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return _buildShadowContainer(
      child: TextFormField(
        controller: _noteController,
        decoration: _customInputDecoration.copyWith(
          labelText: 'Ghi chú (tuỳ chọn)',
          prefixIcon: const Icon(Icons.notes),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.6),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          _isEditing ? 'CẬP NHẬT' : 'TẠO GIAO DỊCH',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.shopping_bag) return 'Mua sắm';
    if (icon == Icons.school) return 'Học tập';
    if (icon == Icons.savings) return 'Tiết kiệm';
    if (icon == Icons.travel_explore) return 'Du lịch';
    if (icon == Icons.work) return 'Công việc';
    if (icon == Icons.sell) return 'Bán hàng';
    if (icon == Icons.favorite) return 'Yêu thích';
    if (icon == Icons.restaurant) return 'Ăn uống';
    if (icon == Icons.local_hospital) return 'Y tế';
    return 'Biểu tượng';
  }

  String _getColorName(Color color) {
    if (color == Colors.purple) return 'Tím';
    if (color == Colors.blue) return 'Xanh dương';
    if (color == Colors.green) return 'Xanh lá';
    if (color == Colors.pinkAccent) return 'Hồng';
    if (color == Colors.orange) return 'Cam';
    if (color == Colors.red) return 'Đỏ';
    if (color == Colors.teal) return 'Xanh ngọc';
    if (color == Colors.brown) return 'Nâu';
    if (color == Colors.indigo) return 'Chàm';
    return 'Màu';
  }
}