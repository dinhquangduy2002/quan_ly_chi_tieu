// lib/features/wallet/domain/entities/wallet_entity.dart
class WalletEntity {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double availableBalance;

  const WalletEntity({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.availableBalance,
  });
}