// wallet_entity.dart
class WalletEntity {
  final String id;
  final String userId;
  final double totalBalance;        // Số dư THẬT trong ví
  final double monthlyIncome;       // Thu nhập THẬT của tháng
  final double monthlyExpense;      // Chi tiêu THẬT của tháng
  final double availableBalance;    // Số dư khả dụng THẬT
  final DateTime updatedAt;

  const WalletEntity({
    required this.id,
    required this.userId,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.availableBalance,
    required this.updatedAt,
  });

  // Ví mặc định khi user đăng ký
  factory WalletEntity.defaultWallet(String userId) {
    return WalletEntity(
      id: 'main',
      userId: userId,
      totalBalance: 0.0,
      monthlyIncome: 0.0,
      monthlyExpense: 0.0,
      availableBalance: 0.0,
      updatedAt: DateTime.now(),
    );
  }

  WalletEntity copyWith({
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyExpense,
    double? availableBalance,
    DateTime? updatedAt,
  }) {
    return WalletEntity(
      id: id,
      userId: userId,
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      availableBalance: availableBalance ?? this.availableBalance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}