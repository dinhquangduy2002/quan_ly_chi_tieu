// File: lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Giả định AppColors đã được định nghĩa
import '../../../../core/presentation/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart'; // Thêm thư viện này để vẽ biểu đồ

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mock data - Giữ nguyên mock data cơ bản
  double _totalBalance = 15.840; // Số dư tổng
  double _monthlyIncome = 5.200; // Thu nhập tháng
  double _monthlyExpense = 10.500; // Chi tiêu tháng

  // Trạng thái cho tab Chi/Thu
  String _selectedType = 'Chi'; // 'Chi' hoặc 'Thu'

  // --- MOCK DATA MỚI ---
  // Mock data cho giao dịch Chi tiêu
  final List<_TransactionItem> _expenseTransactions = [
    _TransactionItem(
      icon: Icons.shopping_bag,
      title: 'Tiền siêu thị',
      description: 'Chi tiêu hàng ngày',
      amount: -250.000,
      time: '02/06/23',
      color: Colors.pink,
    ),
    _TransactionItem(
      icon: Icons.fastfood,
      title: 'Ăn uống ngoài',
      description: 'Cơm trưa văn phòng',
      amount: -120.000,
      time: '02/06/23',
      color: Colors.orange,
    ),
    _TransactionItem(
      icon: Icons.restaurant,
      title: 'Thanh toán nhà hàng',
      description: 'Gặp mặt khách hàng',
      amount: -450.000,
      time: '01/06/23',
      color: Colors.red,
    ),
  ];

  // Mock data cho giao dịch Thu nhập (ĐÃ THÊM MỚI)
  final List<_TransactionItem> _incomeTransactions = [
    _TransactionItem(
      icon: Icons.work,
      title: 'Lương tháng 6',
      description: 'Công ty ABC',
      amount: 25000.000,
      time: '01/06/23',
      color: Colors.green, // Màu xanh cho Thu nhập
    ),
    _TransactionItem(
      icon: Icons.savings,
      title: 'Hoàn tiền dự án',
      description: 'Hoàn chi phí',
      amount: 1500.000,
      time: '28/05/23',
      color: Colors.teal,
    ),
  ];
  // -----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền trắng
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Khu vực Số dư (Chi/Thu) và Tab switch
              _buildMonthlyBalanceSection(),
              const SizedBox(height: 24),

              // Tiêu đề giao dịch gần đây
              _buildRecentTransactionsHeader(),
              const SizedBox(height: 16),

              // List giao dịch gần đây HOẶC trạng thái rỗng
              _buildTransactionListOrEmptyState(),

              const SizedBox(height: 24),

              // Khu vực Tổng quan (Graph)
              _buildOverviewSection(),

              const SizedBox(height: 80), // Thêm khoảng trống cuối
            ],
          ),
        ),
      ),
    );
  }

  // Header (ĐÃ THÊM ICON TÌM KIẾM)
  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final userName = 'Hồng';

    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Welcome text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào,',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Icon Tìm kiếm (ĐÃ THÊM)
        IconButton(
          icon: Icon(
            Icons.search,
            color: AppColors.textPrimary,
            size: 28,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8), // Thêm khoảng cách giữa 2 icon

        // Notification icon
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
            size: 28,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  // Khu vực Số dư hàng tháng và Tab Switch (Giữ nguyên)
  Widget _buildMonthlyBalanceSection() {
    // Dữ liệu hiển thị dựa trên tab đang chọn
    final bool isExpense = _selectedType == 'Chi';
    final double amount = isExpense ? _monthlyExpense : _monthlyIncome;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Text(
            'Số dư bạn ${_selectedType.toLowerCase()} chỉ trong tháng',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          // Số tiền
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                // Định dạng tiền tệ
                '${amount.toStringAsFixed(3)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              // Số dư còn lại (hardcode)
              Text(
                '0 VND',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Switch (Chi & Thu)
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

  // Button cho Tab Switch (Giữ nguyên)
  Widget _buildTabButton(String label, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
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


  // Header giao dịch gần đây (Giữ nguyên)
  Widget _buildRecentTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Giao dịch gần đây',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Xem thêm',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // Hiển thị danh sách giao dịch hoặc trạng thái rỗng (ĐÃ CẬP NHẬT LOGIC)
  Widget _buildTransactionListOrEmptyState() {
    final bool isExpense = _selectedType == 'Chi';
    final List<_TransactionItem> transactions = isExpense ? _expenseTransactions : _incomeTransactions;
    final double monthlyAmount = isExpense ? _monthlyExpense : _monthlyIncome;

    // Nếu có dữ liệu trong danh sách
    if (transactions.isNotEmpty && monthlyAmount > 0) {
      return Column(
        children: transactions.map((transaction) => _buildTransactionItem(transaction)).toList(),
      );
    }
    // Trạng thái rỗng
    else {
      return _buildEmptyTransactionsState();
    }
  }

  // Widget trạng thái rỗng (Giữ nguyên)
  Widget _buildEmptyTransactionsState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 60, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text(
              'Bạn chưa có giao dịch gần đây',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {},
              child: Text(
                'Tạo giao dịch',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Item giao dịch (Cập nhật để hiển thị màu sắc động)
  Widget _buildTransactionItem(_TransactionItem transaction) {
    // Xác định màu sắc cho số tiền: Xanh (Income) hoặc Đỏ (Expense)
    final bool isIncome = transaction.amount > 0;
    final Color amountColor = isIncome ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Icon
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

          // Content
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
                  transaction.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Amount & Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                // Thêm dấu '+' nếu là thu nhập, đảm bảo hiển thị đúng định dạng
                '${isIncome ? '+' : ''}${transaction.amount.toStringAsFixed(3)} VND',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                ),
              ),
              Text(
                transaction.time,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Khu vực Tổng quan (Graph)
  Widget _buildOverviewSection() {
    // Dữ liệu hiển thị dựa trên tab đang chọn
    final bool isExpense = _selectedType == 'Chi';
    final double amount = isExpense ? _monthlyExpense : _monthlyIncome;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề Tổng quan
        const Text(
          'Tổng quan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Dropdown Tháng này (giả định)
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Tháng này',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
          ],
        ),
        const SizedBox(height: 20),

        // Card chứa Số tiền và Biểu đồ
        Container(
          padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Số tiền Tổng quan
              Text(
                '${amount.toStringAsFixed(3)} VND',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // Số liệu phụ (giả định)
              Text(
                'Số liệu chi/thu trong tháng này',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Biểu đồ (chỉ hiển thị nếu có dữ liệu)
              if (amount > 0)
                SizedBox(
                  height: 200,
                  child: LineChart(
                    _mainData(isExpense),
                  ),
                )
              else
              // Trạng thái rỗng cho biểu đồ
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'Chưa có dữ liệu giao dịch trong tháng',
                      style: TextStyle(color: AppColors.textLight),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Dữ liệu và cấu hình cho biểu đồ (ĐÃ SỬA LỖI getHorizontalLine -> getDrawingHorizontalLine)
  LineChartData _mainData(bool isExpense) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        // ĐÃ SỬA LỖI: dùng getDrawingHorizontalLine thay cho getHorizontalLine
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.border,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              // Mock labels (11/6, 12/6, ...)
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = const Text('11/6', style: style);
                  break;
                case 2:
                  text = const Text('12/6', style: style);
                  break;
                case 4:
                  text = const Text('13/6', style: style);
                  break;
                case 6:
                  text = const Text('14/6', style: style);
                  break;
                case 8:
                  text = const Text('15/6', style: style);
                  break;
                case 10:
                  text = const Text('16/6', style: style);
                  break;
                case 12:
                  text = const Text('17/6', style: style);
                  break;
                default:
                  text = const Text('', style: style);
                  break;
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: text,
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 200, // Khoảng cách 200, 400, 600...
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text = value.toInt().toString();
              return Text(text, style: style, textAlign: TextAlign.left);
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false, // Bỏ border
      ),
      // Giới hạn trục Y (từ 0 đến 800)
      minX: 0,
      maxX: 12,
      minY: 0,
      maxY: 800,
      lineBarsData: [
        LineChartBarData(
          // Dữ liệu mock để vẽ sóng
          spots: const [
            FlSpot(0, 100),
            FlSpot(1.5, 300),
            FlSpot(3, 200),
            FlSpot(4.5, 450),
            FlSpot(6, 600), // Điểm cao nhất ở giữa
            FlSpot(7.5, 500),
            FlSpot(9, 350),
            FlSpot(10.5, 400),
            FlSpot(12, 300),
          ],
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            // Chỉ hiển thị chấm ở điểm 600 (như trong Figma)
            getDotPainter: (spot, percent, barData, index) {
              if (index == 5) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeColor: AppColors.primary,
                  strokeWidth: 3,
                );
              }
              return FlDotCirclePainter(
                radius: 0,
                color: Colors.transparent,
                strokeColor: Colors.transparent,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            // Gradient màu xanh nhẹ
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.5),
                AppColors.primary.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

// Class Transaction Item (Giữ nguyên)
class _TransactionItem {
  final IconData icon;
  final String title;
  final String description;
  final double amount;
  final String time;
  final Color color;

  _TransactionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.amount,
    required this.time,
    required this.color,
  });
}